package com.yazilimceosu.ezanai

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Ana ekran widget'ı: sıradaki vakit, saati ve **canlı geri sayım**.
 *
 * Veriyi Flutter tarafı (`ezanai/widget` kanalı) yazar; widget yalnızca yerel
 * `SharedPreferences` dosyasını okur. Böylece widget, uygulama kapalıyken de
 * internet/pil harcamadan çalışır. Geri sayım `Chronometer` bileşeniyle
 * sistem tarafından çizilir (API 24+); daha eski cihazlarda yalnızca saat
 * gösterilir.
 */
class EzanWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val views = buildViews(context)
        for (appWidgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_REFRESH) {
            updateAll(context)
        }
    }

    companion object {
        const val ACTION_REFRESH = "com.yazilimceosu.ezanai.WIDGET_REFRESH"

        private const val PREFS = "ezan_widget"

        /** Flutter'dan gelen güncel vakit bilgisini kaydeder ve widget'ı yeniler. */
        fun updateFromPayload(
            context: Context,
            city: String,
            prayer: String,
            time: String,
            targetMillis: Long,
            hijri: String,
        ) {
            try {
                context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                    .edit()
                    .putString("city", city)
                    .putString("prayer", prayer)
                    .putString("time", time)
                    .putLong("target", targetMillis)
                    .putString("hijri", hijri)
                    .apply()
            } catch (_: Throwable) {
                return
            }
            updateAll(context)
        }

        fun updateAll(context: Context) {
            try {
                val manager = AppWidgetManager.getInstance(context) ?: return
                val component = ComponentName(context, EzanWidgetProvider::class.java)
                val ids = manager.getAppWidgetIds(component)
                if (ids.isEmpty()) return
                val views = buildViews(context)
                for (id in ids) {
                    manager.updateAppWidget(id, views)
                }
            } catch (_: Throwable) {}
        }

        private fun buildViews(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.ezan_widget)
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val city = prefs.getString("city", "") ?: ""
            val prayer = prefs.getString("prayer", "") ?: ""
            val time = prefs.getString("time", "--:--") ?: "--:--"
            val hijri = prefs.getString("hijri", "") ?: ""
            val target = prefs.getLong("target", 0L)

            views.setTextViewText(
                R.id.widget_sehir,
                city.ifBlank { "Ezan Vaktim Pro" },
            )
            views.setTextViewText(
                R.id.widget_vakit,
                prayer.ifBlank { "Vakitler hazırlanıyor" },
            )
            views.setTextViewText(R.id.widget_saat, time)
            views.setTextViewText(
                R.id.widget_hicri,
                hijri.ifBlank { todayLabel() },
            )

            val remaining = target - System.currentTimeMillis()
            if (remaining > 0 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                // Chronometer, duvar saati değil `elapsedRealtime` tabanıyla
                // çalışır: kalan süreyi şimdiki ana ekleyip geri sayıma veriyoruz.
                val base = SystemClock.elapsedRealtime() + remaining
                views.setChronometer(R.id.widget_geri_sayim, base, null, true)
                views.setChronometerCountDown(R.id.widget_geri_sayim, true)
            } else if (remaining > 0) {
                views.setTextViewText(
                    R.id.widget_geri_sayim,
                    "Kalan: ${formatDuration(remaining)}",
                )
            } else {
                views.setTextViewText(R.id.widget_geri_sayim, "Uygulamayı açın")
            }

            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                views.setOnClickPendingIntent(R.id.widget_kok, pendingIntent)
            }
            return views
        }

        private fun formatDuration(millis: Long): String {
            val totalMinutes = (millis / 60000L).coerceAtLeast(0L)
            val hours = totalMinutes / 60L
            val minutes = totalMinutes % 60L
            return if (hours > 0) "${hours}s ${minutes}dk" else "${minutes}dk"
        }

        private fun todayLabel(): String = try {
            SimpleDateFormat("d MMMM EEEE", Locale("tr", "TR")).format(Date())
        } catch (_: Throwable) {
            ""
        }
    }
}
