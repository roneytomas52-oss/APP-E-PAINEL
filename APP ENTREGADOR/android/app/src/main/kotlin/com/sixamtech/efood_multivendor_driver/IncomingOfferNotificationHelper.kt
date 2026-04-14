package com.sixamtech.sixam_mart_delivery_app

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.util.UUID

object IncomingOfferNotificationHelper {

    private const val CHANNEL_ID = "incoming_offer_events"
    private const val CHANNEL_NAME = "Incoming offers"
    private const val CHANNEL_DESCRIPTION = "Native incoming-offer actions bridge"

    fun showIncomingOfferNotification(
        context: Context,
        orderId: String?,
        type: String?,
        notificationType: String?,
        title: String?,
        body: String?,
        expiresInMs: Long = DEFAULT_EXPIRE_MS,
    ) {
        createNotificationChannel(context)

        val notificationId = resolveNotificationId(orderId)
        val eventToken = UUID.randomUUID().toString()

        val openIntent = buildActionIntent(
            context = context,
            action = IncomingOfferContract.ACTION_OFFER_OPEN,
            orderId = orderId,
            type = type,
            notificationType = notificationType,
            title = title,
            body = body,
            eventToken = eventToken,
            notificationId = notificationId,
            requestCode = notificationId + 1,
        )
        val acceptIntent = buildActionIntent(
            context = context,
            action = IncomingOfferContract.ACTION_OFFER_ACCEPT,
            orderId = orderId,
            type = type,
            notificationType = notificationType,
            title = title,
            body = body,
            eventToken = eventToken,
            notificationId = notificationId,
            requestCode = notificationId + 2,
        )
        val declineIntent = buildActionIntent(
            context = context,
            action = IncomingOfferContract.ACTION_OFFER_DECLINE,
            orderId = orderId,
            type = type,
            notificationType = notificationType,
            title = title,
            body = body,
            eventToken = eventToken,
            notificationId = notificationId,
            requestCode = notificationId + 3,
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.notification_icon)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setContentTitle(title ?: "Nova oferta")
            .setContentText(body ?: "Você recebeu uma nova oferta.")
            .setContentIntent(openIntent)
            .addAction(0, "Aceitar", acceptIntent)
            .addAction(0, "Recusar", declineIntent)
            .setTimeoutAfter(expiresInMs)
            .build()

        NotificationManagerCompat.from(context).notify(notificationId, notification)
        scheduleExpiryBroadcast(
            context = context,
            orderId = orderId,
            type = type,
            notificationType = notificationType,
            title = title,
            body = body,
            eventToken = eventToken,
            notificationId = notificationId,
            expiresAt = System.currentTimeMillis() + expiresInMs,
            requestCode = notificationId + 4,
        )
    }

    fun resolveNotificationId(orderId: String?): Int {
        return orderId?.hashCode()?.let { kotlin.math.abs(it) } ?: (System.currentTimeMillis() % Int.MAX_VALUE).toInt()
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH).apply {
            description = CHANNEL_DESCRIPTION
            lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
        }
        val manager = context.getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
    }

    private fun buildActionIntent(
        context: Context,
        action: String,
        orderId: String?,
        type: String?,
        notificationType: String?,
        title: String?,
        body: String?,
        eventToken: String,
        notificationId: Int,
        requestCode: Int,
    ): PendingIntent {
        val intent = Intent(context, IncomingOfferActionReceiver::class.java).apply {
            this.action = action
            putExtra(IncomingOfferContract.EXTRA_ORDER_ID, orderId)
            putExtra(IncomingOfferContract.EXTRA_TYPE, type)
            putExtra(IncomingOfferContract.EXTRA_NOTIFICATION_TYPE, notificationType)
            putExtra(IncomingOfferContract.EXTRA_TITLE, title)
            putExtra(IncomingOfferContract.EXTRA_BODY, body)
            putExtra(IncomingOfferContract.EXTRA_EVENT_TOKEN, eventToken)
            putExtra(IncomingOfferContract.EXTRA_NOTIFICATION_ID, notificationId)
        }

        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun scheduleExpiryBroadcast(
        context: Context,
        orderId: String?,
        type: String?,
        notificationType: String?,
        title: String?,
        body: String?,
        eventToken: String,
        notificationId: Int,
        expiresAt: Long,
        requestCode: Int,
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val expireIntent = buildActionIntent(
            context = context,
            action = IncomingOfferContract.ACTION_OFFER_EXPIRE,
            orderId = orderId,
            type = type,
            notificationType = notificationType,
            title = title,
            body = body,
            eventToken = eventToken,
            notificationId = notificationId,
            requestCode = requestCode,
        )
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, expiresAt, expireIntent)
    }

    private const val DEFAULT_EXPIRE_MS = 45_000L
}
