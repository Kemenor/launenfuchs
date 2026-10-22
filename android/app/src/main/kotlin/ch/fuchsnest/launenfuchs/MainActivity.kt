package ch.fuchsnest.launenfuchs

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth (app lock) needs a FragmentActivity.
class MainActivity : FlutterFragmentActivity() {
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "launenfuchs/reminder",
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "sync" -> {
                        Reminder.sync(
                            this@MainActivity,
                            call.argument<List<Number>>("times")!!
                                .map { it.toLong() },
                            Reminder.Texts(
                                title = call.argument("title")!!,
                                body = call.argument("body")!!,
                                channelName = call.argument("channelName")!!,
                                channelDescription =
                                    call.argument("channelDescription")!!,
                                moods = call.argument("moods")!!,
                            ),
                        )
                        if (call.argument<Boolean>("todayLogged") == true) {
                            Reminder.dismiss(this@MainActivity)
                        }
                        result.success(null)
                    }
                    // A cold start from the reminder: the tap, once.
                    "launchTap" -> result.success(takeTap(intent))
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        takeTap(intent)?.let { channel?.invokeMethod("tap", it) }
    }

    /** The mood of a reminder tap (0 = the text, no face), or null. */
    private fun takeTap(intent: Intent?): Int? {
        if (intent?.action != Reminder.ACTION_OPEN) return null
        val mood = intent.getIntExtra(Reminder.EXTRA_MOOD, 0)
        // Consumed: a re-created activity mustn't open the entry again.
        intent.action = Intent.ACTION_MAIN
        Reminder.dismiss(this)
        return mood
    }
}
