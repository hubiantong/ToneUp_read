import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:toneup_read/services/app_config_service.dart';
import 'package:toneup_read/services/db_service.dart';
import 'package:toneup_read/services/http_service.dart';
import 'package:toneup_read/services/llm_service.dart';
import 'package:toneup_read/services/vocab_service.dart';

class _SyncDb extends DbService {
  _SyncDb({required this.pages, this.existingHeads = const []});

  final List<List<Map<String, dynamic>>> pages;
  final List<Map<String, dynamic>> existingHeads;
  final List<List<Object?>?> inserts = [];
  final List<List<Object?>?> updates = [];
  int pageQueries = 0;

  @override
  Future<List<Map<String, dynamic>>> select(String sql, [List<Object?>? params]) async {
    if (sql.startsWith('SELECT head FROM vocab_head')) {
      return [for (final h in existingHeads) {'head': h['head']}];
    }
    if (sql.startsWith('SELECT head, zh FROM vocab_head')) {
      return [for (final h in existingHeads) {'head': h['head'], 'zh': h['zh']}];
    }
    if (sql.contains('FROM word_cache') && sql.contains('ORDER BY rowid')) {
      final i = pageQueries++;
      if (i >= pages.length) return [];
      return [for (final r in pages[i]) Map<String, dynamic>.of(r)];
    }
    return [];
  }

  @override
  Future<void> execute(String sql, [List<Object?>? params]) async {
    if (sql.startsWith('INSERT OR IGNORE INTO vocab_head')) inserts.add(params);
    if (sql.startsWith('UPDATE vocab_head SET zh')) updates.add(params);
  }
}

VocabService _svc(_SyncDb db) => VocabService(db, LlmService(HttpService(), AppConfigService()));

String _result(String word) => jsonEncode({
      'kind': 'dict',
      'senses': [
        {'pos': 'n', 'definition': '$word 的释义', 'en': 'definition of $word'}
      ],
    });

List<Map<String, dynamic>> _rows(int from, int count) => [
      for (var i = 0; i < count; i++)
        {
          'rid': from + i,
          'word': 'w${from + i}',
          'lemma': null,
          'at': 1700000000000 + i,
          'result': _result('w${from + i}'),
        }
    ];

void main() {
  test('syncHeadsFromCache 按 rowid 分页读取并回填 zh', () async {
    final db = _SyncDb(pages: [_rows(1, 100), _rows(101, 1)]);
    await _svc(db).syncHeadsFromCache();

    expect(db.pageQueries, 2, reason: '100 + 1 行应读取两页');
    expect(db.inserts, hasLength(101));
    final first = db.inserts.first!;
    expect(first[0], 'w1');
    expect(first[9], 'w1 的释义');
  });

  test('syncHeadsFromCache 对已有空 zh 的词条只 UPDATE，不重复插入', () async {
    final db = _SyncDb(
      pages: [_rows(1, 2)],
      existingHeads: [
        {'head': 'w1', 'zh': ''},
      ],
    );
    await _svc(db).syncHeadsFromCache();

    expect(db.updates, hasLength(1));
    expect(db.updates.single, ['w1 的释义', 'w1']);
    expect(db.inserts, hasLength(1), reason: 'w1 已存在，只应插入 w2');
    expect(db.inserts.single![0], 'w2');
  });

  test('syncHeadsFromCache 进程内只跑一次', () async {
    final db = _SyncDb(pages: [_rows(1, 1)]);
    final svc = _svc(db);
    await svc.syncHeadsFromCache();
    await svc.syncHeadsFromCache();

    expect(db.pageQueries, 1);
    expect(db.inserts, hasLength(1));
  });
}
