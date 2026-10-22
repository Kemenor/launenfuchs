package ch.fuchsnest.launenfuchs

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * The daily reminder on Android (design-concept §2.8): one-off inexact alarms
 * at the times Dart computed (logged days already left out), and a
 * notification with the five moods — a face opens today's entry with that
 * mood picked. The times and texts live in prefs so a reboot can re-arm them.
 */
object Reminder {
    const val ACTION_OPEN = "ch.fuchsnest.launenfuchs.REMINDER"
    const val EXTRA_MOOD = "mood"

    // Same id as the flutter_local_notifications channel it replaces, so the
    // user's sound/importance choices carry over.
    private const val CHANNEL_ID = "daily-reminder"
    private const val NOTIFICATION_ID = 1
    private const val MAX_ALARMS = 31
    private const val PREFS = "launenfuchs_reminder"

    private val faceIds = mapOf(
        1 to R.id.mood_1,
        2 to R.id.mood_2,
        3 to R.id.mood_3,
        4 to R.id.mood_4,
        5 to R.id.mood_5,
    )

    data class Texts(
        val title: String,
        val body: String,
        val channelName: String,
        val channelDescription: String,
        /** Mood labels by value 1…5, for TalkBack. */
        val moods: List<String>,
    )

    /** Replaces the schedule with [times] (epoch ms; empty = off). */
    fun sync(context: Context, times: List<Long>, texts: Texts) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        prefs.edit()
            .putString("times", times.joinToString(","))
            .putString("title", texts.title)
            .putString("body", texts.body)
            .putString("channelName", texts.channelName)
            .putString("channelDescription", texts.channelDescription)
            .putString("moods", texts.moods.joinToString("\n"))
            .apply()
        arm(context, times)
    }

    /** After a reboot or an app update: re-arm what's still ahead. */
    fun rearm(context: Context) {
        val now = System.currentTimeMillis()
        arm(context, storedTimes(context).filter { it > now })
    }

    fun dismiss(context: Context) {
        context.getSystemService(NotificationManager::class.java)
            .cancel(NOTIFICATION_ID)
    }

    private fun storedTimes(context: Context): List<Long> =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString("times", "")!!
            .split(",")
            .mapNotNull { it.toLongOrNull() }

    private fun arm(context: Context, times: List<Long>) {
        val alarms = context.getSystemService(AlarmManager::class.java)
        for (i in 0 until MAX_ALARMS) alarms.cancel(alarmIntent(context, i))
        times.take(MAX_ALARMS).forEachIndexed { i, at ->
            // Inexact: no exact-alarm permission, a few minutes' drift is fine.
            alarms.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                at,
                alarmIntent(context, i),
            )
        }
    }

    private fun alarmIntent(context: Context, slot: Int): PendingIntent =
        PendingIntent.getBroadcast(
            context,
            slot,
            Intent(context, ReminderReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

    fun texts(context: Context): Texts? {
        val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val title = p.getString("title", null) ?: return null
        return Texts(
            title = title,
            body = p.getString("body", "")!!,
            channelName = p.getString("channelName", title)!!,
            channelDescription = p.getString("channelDescription", "")!!,
            moods = p.getString("moods", "")!!.split("\n"),
        )
    }

    fun show(context: Context) {
        val texts = texts(context) ?: return
        val manager = context.getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                texts.channelName,
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply { description = texts.channelDescription },
        )
        val collapsed = faces(context, R.layout.reminder_faces, texts)
        val expanded = faces(context, R.layout.reminder_expanded, texts).apply {
            setTextViewText(R.id.title, texts.title)
            setTextViewText(R.id.body, texts.body)
        }
        val notification = Notification.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            // Shown where the custom view isn't (lock screen, watches).
            .setContentTitle(texts.title)
            .setContentText(texts.body)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(collapsed)
            .setCustomBigContentView(expanded)
            .setContentIntent(openIntent(context, mood = 0))
            .setAutoCancel(true)
            .build()
        manager.notify(NOTIFICATION_ID, notification)
    }

    private fun faces(context: Context, layout: Int, texts: Texts) =
        RemoteViews(context.packageName, layout).apply {
            for ((mood, id) in faceIds) {
                setOnClickPendingIntent(id, openIntent(context, mood))
                texts.moods.getOrNull(mood - 1)?.let {
                    setContentDescription(id, it)
                }
            }
        }

    /** Opens the app on today's entry; [mood] 1…5 pre-picks a face, 0 none. */
    private fun openIntent(context: Context, mood: Int): PendingIntent =
        PendingIntent.getActivity(
            context,
            100 + mood,
            Intent(context, MainActivity::class.java)
                .setAction(ACTION_OPEN)
                .putExtra(EXTRA_MOOD, mood)
                .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
}

/** Fires the reminder; re-arms the schedule after a reboot or an update. */
class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> Reminder.rearm(context)
            else -> Reminder.show(context)
        }
    }
}
