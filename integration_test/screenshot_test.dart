import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' show deleteDatabase, getDatabasesPath;

import 'package:toneup_read/models/models.dart';
import 'package:toneup_read/providers/providers.dart';
import 'package:toneup_read/screens/article_screen.dart';
import 'package:toneup_read/screens/home_screen.dart';
import 'package:toneup_read/screens/mine_screen.dart';
import 'package:toneup_read/screens/review_screen.dart';
import 'package:toneup_read/screens/sentence_screen.dart';
import 'package:toneup_read/screens/vocab_screen.dart';
import 'package:toneup_read/services/app_config_service.dart';
import 'package:toneup_read/services/db_service.dart';
import 'package:toneup_read/services/http_service.dart';
import 'package:toneup_read/services/llm_service.dart';
import 'package:toneup_read/services/remote_article_service.dart';
import 'package:toneup_read/services/translate_service.dart';
import 'package:toneup_read/theme/app_theme.dart';

/// 真机 / 模拟器截图：flutter drive --driver=test_driver/screenshot_driver.dart \
///   --target=integration_test/screenshot_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late DbService db;
  late AppConfigService cfg;
  late String dbPath;
  int articleId = 0;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'article_api_key': 'shot-key',
      'gateway_key': 'shot-key',
    });
    cfg = AppConfigService();
    await cfg.init();

    final dir = await getDatabasesPath();
    dbPath = '$dir/toneup_shot.db';
    await deleteDatabase(dbPath);
    db = DbService(dbPath: dbPath);
    await db.database;

    final now = DateTime.now().millisecondsSinceEpoch;
    const paras = [
      'Climate tipping points are thresholds that, once crossed, can lead to abrupt and irreversible changes in the Earth system.',
      'Scientists warn that the window to keep global warming within safe limits is closing faster than expected.',
      'Renewable energy, electric transport and healthier diets are among the most effective ways to cut emissions.',
      'Yet progress remains uneven, and the countries least responsible for historical emissions often face the greatest risks.',
      'The choices made in this decade will shape the climate inherited by future generations.',
    ];
    final blocks = [for (final t in paras) ArticleBlock(type: 'p', text: t)];
    articleId = await db.insertReturnId(
      'INSERT INTO articles (guid, title, sourceUrl, plainText, blocks, wordCount, capturedAt, cachedAt, source, publishedAt, status) '
      'VALUES (?,?,?,?,?,?,?,?,?,?,?)',
      [
        'https://example.com/climate',
        'Climate Tipping Points Are Closer Than We Think',
        'https://example.com/climate',
        paras.join('\n\n'),
        jsonEncode(blocks.map((b) => b.toJson()).toList()),
        120,
        now,
        now,
        'BBC News',
        now,
        'accepted',
      ],
    );

    const heads = [
      ('privacy', 'n. 隐私；私密'),
      ('emission', 'n. 排放；排放物'),
      ('renewable', 'adj. 可再生的'),
      ('threshold', 'n. 门槛；临界点'),
      ('irreversible', 'adj. 不可逆的'),
      ('generation', 'n. 一代人；产生'),
    ];
    for (var i = 0; i < heads.length; i++) {
      await db.execute(
        'INSERT INTO vocab_head (head, kind, firstSeen, lastSeen, occCount, fsrs_state, fsrs_due, fsrs_s, fsrs_d, zh) '
        'VALUES (?,?,?,?,?,?,?,?,?,?)',
        [heads[i].$1, 'word', now - i * 1000, now - i * 1000, i + 1, 0, i < 2 ? now - 1000 : now + 86400000, 1.0, 5.0, heads[i].$2],
      );
    }

    await db.execute(
      'INSERT INTO vocab_sentence (sentence, articleGuid, articleTitle, sourceLabel, paraIndex, tokIndex, at) VALUES (?,?,?,?,?,?,?)',
      [
        'The choices made in this decade will shape the climate inherited by future generations.',
        'https://example.com/climate',
        'Climate Tipping Points Are Closer Than We Think',
        'BBC News',
        4,
        0,
        now,
      ],
    );
    await db.execute(
      'INSERT INTO vocab_sentence (sentence, articleGuid, articleTitle, sourceLabel, paraIndex, tokIndex, at) VALUES (?,?,?,?,?,?,?)',
      [
        'Yet progress remains uneven, and the countries least responsible for historical emissions often face the greatest risks.',
        'https://example.com/climate',
        'Climate Tipping Points Are Closer Than We Think',
        'BBC News',
        3,
        0,
        now - 1000,
      ],
    );
  });

  tearDownAll(() async {
    try {
      await deleteDatabase(dbPath);
    } catch (_) {}
  });

  Widget app(Widget home, {ThemeData? theme}) => ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          appConfigProvider.overrideWith((ref) => cfg),
          remoteArticleProvider.overrideWith((ref) => _ShotRemote(db, cfg)),
        ],
        child: MaterialApp(theme: theme ?? buildDarkTheme(), home: home),
      );

  Future<void> shot(WidgetTester tester, String name, Widget home, {ThemeData? theme}) async {
    await tester.pumpWidget(app(home, theme: theme));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot(name);
  }

  testWidgets('界面预览截图', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    await shot(tester, '01_home', const HomeScreen());
    await shot(tester, '02_home_light', const HomeScreen(), theme: buildLightTheme());
    await shot(tester, '03_reader', ArticleScreen(articleId: articleId));
    await shot(tester, '04_vocab', const VocabScreen());
    await shot(tester, '05_sentence', const SentenceScreen());
    await shot(tester, '06_review', const ReviewScreen());
    await shot(tester, '07_mine', const MineScreen());

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });
}

class _ShotRemote extends RemoteArticleService {
  _ShotRemote(DbService db, AppConfigService cfg)
      : super(db, HttpService(), cfg, TranslateService(LlmService(HttpService(), cfg)));

  static const _items = <Map<String, dynamic>>[
    {
      'id': 101,
      'title': 'Climate Tipping Points Are Closer Than We Think',
      'source': 'BBC News',
      'url': 'https://example.com/climate',
      'published_at': 1760000000,
      'word_count': 120,
    },
    {
      'id': 102,
      'title': 'The Quiet Rise of Pocket Solar Power',
      'source': 'The Economist',
      'url': 'https://example.com/solar',
      'published_at': 1759900000,
      'word_count': 860,
    },
    {
      'id': 103,
      'title': 'Why Cities Are Rethinking Public Space',
      'source': 'The Guardian',
      'url': 'https://example.com/cities',
      'published_at': 1759800000,
      'word_count': 1040,
    },
  ];

  @override
  Future<Map<String, dynamic>> list({
    String? source,
    String status = 'accepted',
    String? q,
    DateTime? since,
    DateTime? until,
    int page = 1,
    int perPage = 20,
  }) async {
    return <String, dynamic>{'items': _items, 'total': _items.length, 'page': page, 'perPage': perPage};
  }

  @override
  Future<Map<String, String>> titleZhBatch(List<String> titles) async => {
        'Climate Tipping Points Are Closer Than We Think': '气候临界点比想象更近',
        'The Quiet Rise of Pocket Solar Power': '口袋太阳能的安静崛起',
        'Why Cities Are Rethinking Public Space': '城市为何重新思考公共空间',
      };

  @override
  Future<Set<String>> cachedGuids() async => <String>{};
}
