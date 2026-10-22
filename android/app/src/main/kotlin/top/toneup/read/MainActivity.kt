package top.toneup.read

import android.media.AudioAttributes
import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var player: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 云端 TTS 播放器：只播本地缓存好的 mp3，不引入任何音频插件。
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "toneup/tts_player")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val path = call.arguments as? String
                    if (path == null) {
                        result.error("bad_args", "path is required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        player?.release()
                        player = MediaPlayer().apply {
                            setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setUsage(AudioAttributes.USAGE_MEDIA)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                                    .build()
                            )
                            setDataSource(path)
                            setOnPreparedListener { it.start() }
                            setOnCompletionListener {
                                channel.invokeMethod("completed", null)
                                it.release()
                                player = null
                            }
                            setOnErrorListener { mp, _, _ ->
                                channel.invokeMethod("completed", null)
                                mp.release()
                                player = null
                                true
                            }
                            prepareAsync()
                        }
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("play_failed", e.message, null)
                    }
                }

                "stop" -> {
                    try {
                        player?.stop()
                    } catch (_: Exception) {
                    }
                    player?.release()
                    player = null
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        player?.release()
        player = null
        super.onDestroy()
    }
}
