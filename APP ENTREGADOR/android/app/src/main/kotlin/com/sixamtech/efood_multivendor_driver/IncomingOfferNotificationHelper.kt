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
import java.util.concurrent.ConcurrentHashMap

object IncomingOfferNotificationHelper {

    private const val CHANNEL_ID = "incoming_offer_events"
    private const val CHANNEL_NAME = "Incoming offers"
    private const val CHANNEL_DESCRIPTION = "Native incoming-offer actions bridge"

    private val displayedOffers = ConcurrentHashMap<String, Long>()
    private val consumedOfferTokens = ConcurrentHashMap<String, Long>()

    fun showIncomingOfferNotification(
        context: Context,
        orderId: String?,
        type: String?,
        notificationType: String?,
        title: String?,
        body: String?,
        moduleType: String? = null,
        orderType: String? = null,
        expiresInMs: Long = DEFAULT_EXPIRE_MS,
    ) {
        createNotificationChannel(context)
        IncomingOfferLog.i(
            stage = "offer_received",
            source = IncomingOfferContract.SOURCE_ANDROID_NOTIFICATION,
            orderId = orderId,
            moduleType = moduleType,
            type = type,
            message = "native notification request received",
        )

        val notificationId = resolveNotificationId(orderId)
        val eventToken = UUID.randomUUID().toString()
        val expiresAt = System.currentTimeMillis() + expiresInMs

        val fullScreenIntent = buildOfferActivityIntent(
            context = context,
            orderId = orderId,
            type = type,
            notificationType = notificationType,
            title = title,
            body = body,
            moduleType = moduleType,
            orderType = orderType,
            eventToken = eventToken,
            notificationId = notificationId,
            expiresAt = expiresAt,
            requestCode = notificationId + 90,
        )

        val openIntent = buildActionIntent(
            context = context,
            action = IncomingOfferContract.ACTION_OFFER_OPEN,
            orderId = orderId,
            type = type,
            notificationType = notificationType,
            title = title,
            body = body,
            moduleType = moduleType,
            orderType = orderType,
            eventToken = eventToken,
            notificationId = notificationId,
            expiresAt = expiresAt,
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
            moduleType = moduleType,
            orderType = orderType,
            eventToken = eventToken,
            notificationId = notificationId,
            expiresAt = expiresAt,
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
            moduleType = moduleType,
            orderType = orderType,
            eventToken = eventToken,
            notificationId = notificationId,
            expiresAt = expiresAt,
            requestCode = notificationId + 3,
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.notification_icon)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setOngoing(true)
            .setFullScreenIntent(fullScreenIntent, true)
            .setContentTitle(title ?: "Nova oferta")
            .setContentText(body ?: "Você recebeu uma nova oferta.")
            .setContentIntent(openIntent)
            .addAction(0, "Aceitar", acceptIntent)
            .addAction(0, "Recusar", declineIntent)
            .setTimeoutAfter(expiresInMs)
            .build()

        NotificationManagerCompat.from(context).notify(notificationId, notification)
        IncomingOfferLog.i(
            stage = "notification_created",
            source = IncomingOfferContract.SOURCE_ANDROID_NOTIFICATION,
            orderId = orderId,
            eventToken = eventToken,
            moduleType = moduleType,
            type = type,
        )
        maybeLaunchIncomingOfferActivity(
            context = context,
            orderId = orderId,
            type = type,
            notificationType = notificationType,
            title = title,
            body = body,
            moduleType = moduleType,
            orderType = orderType,
            eventToken = eventToken,
            notificationId = notificationId,
            expiresAt = expiresAt,
            force = false,
        )
        scheduleExpiryBroadcast(
            context = context,
            orderId = orderId,
            type = type,
            notificationType = notificationType,
            title = title,
            body = body,
            moduleType = moduleType,
            orderType = orderType,
            eventToken = eventToken,
            notificationId = notificationId,
            expiresAt = expiresAt,
            requestCode = notificationId + 4,
        )
    }

    fun resolveNotificationId(orderId: String?): Int {
        return orderId?.hashCode()?.let { kotlin.math.abs(it) } ?: (System.currentTimeMillis() % Int.MAX_VALUE).toInt()
    }

    fun maybeLaunchIncomingOfferActivity(
        context: Context,
        orderId: String?,
        type: String?,
        notificationType: String?,
        title: String?,
        body: String?,
        moduleType: String?,
        orderType: String?,
        eventToken: String,
        notificationId: Int,
        expiresAt: Long,
        force: Boolean = false,
    ) {
        if (!force && !shouldBringActivityToFront(orderId, expiresAt)) {
            IncomingOfferLog.i(
                stage = "fallback_triggered",
                source = IncomingOfferContract.SOURCE_ANDROID_NOTIFICATION,
                orderId = orderId,
                eventToken = eventToken,
                moduleType = moduleType,
                type = type,
                message = "takeover launch skipped by shouldBringActivityToFront",
            )
            return
        }

        val intent = Intent(context, IncomingOfferActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putOfferExtras(
                orderId = orderId,
                type = type,
                notificationType = notificationType,
                title = title,
                body = body,
                moduleType = moduleType,
                orderType = orderType,
                eventToken = eventToken,
                notificationId = notificationId,
                expiresAt = expiresAt,
            )
        }

        runCatching {
            context.startActivity(intent)
            markOfferAsDisplayed(orderId, expiresAt)
            IncomingOfferLog.i(
                stage = "activity_opened",
                source = IncomingOfferContract.SOURCE_ANDROID_NOTIFICATION,
                orderId = orderId,
                eventToken = eventToken,
                moduleType = moduleType,
                type = type,
            )
        }
    }

    fun shouldBringActivityToFront(orderId: String?, expiresAt: Long): Boolean {
        if (orderId.isNullOrBlank()) {
            return true
        }
        val now = System.currentTimeMillis()
        displayedOffers.entries.removeIf { (_, value) -> value <= now }
        val existingExpiry = displayedOffers[orderId] ?: return true
        return existingExpiry < now || existingExpiry < expiresAt
    }

    fun markOfferAsDisplayed(orderId: String?, expiresAt: Long = System.currentTimeMillis() + DEFAULT_EXPIRE_MS) {
        if (orderId.isNullOrBlank()) {
            return
        }
        displayedOffers[orderId] = expiresAt
    }

    fun clearOfferTracking(orderId: String?) {
        if (orderId.isNullOrBlank()) {
            return
        }
        displayedOffers.remove(orderId)
        IncomingOfferLog.i(
            stage = "cleanup_executed",
            source = IncomingOfferContract.SOURCE_ANDROID_NOTIFICATION,
            orderId = orderId,
            message = "displayed offer tracking removed",
        )
    }

    fun consumeActionToken(eventToken: String?, expiresAt: Long): Boolean {
        if (eventToken.isNullOrBlank()) {
            return true
        }
        val now = System.currentTimeMillis()
        consumedOfferTokens.entries.removeIf { (_, value) -> value <= now }
        val tokenExpiry = if (expiresAt > now) expiresAt else now + DEFAULT_EXPIRE_MS
        val previous = consumedOfferTokens.putIfAbsent(eventToken, tokenExpiry)
        if (previous != null) {
            IncomingOfferLog.i(
                stage = "dedupe_discarded",
                source = IncomingOfferContract.SOURCE_ANDROID_RECEIVER,
                eventToken = eventToken,
                message = "duplicate action token",
            )
        }
        return previous == null
    }

    fun cancelExpiryBroadcast(context: Context, notificationId: Int?) {
        val validNotificationId = notificationId ?: return
        val requestCode = validNotificationId + 4
        val intent = Intent(context, IncomingOfferActionReceiver::class.java).apply {
            action = IncomingOfferContract.ACTION_OFFER_EXPIRE
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
        ) ?: return
        (context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager)?.cancel(pendingIntent)
        pendingIntent.cancel()
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

    private fun buildOfferActivityIntent(
        context: Context,
        orderId: String?,
        type: String?,
        notificationType: String?,
        title: String?,
        body: String?,
        moduleType: String?,
        orderType: String?,
        eventToken: String,
        notificationId: Int,
        expiresAt: Long,
        requestCode: Int,
    ): PendingIntent {
        val intent = Intent(context, IncomingOfferActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putOfferExtras(
                orderId = orderId,
                type = type,
                notificationType = notificationType,
                title = title,
                body = body,
                moduleType = moduleType,
                orderType = orderType,
                eventToken = eventToken,
                notificationId = notificationId,
                expiresAt = expiresAt,
            )
        }

        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun buildActionIntent(
        context: Context,
        action: String,
        orderId: String?,
        type: String?,
        notificationType: String?,
        title: String?,
        body: String?,
        moduleType: String?,
        orderType: String?,
        eventToken: String,
        notificationId: Int,
        expiresAt: Long,
        requestCode: Int,
    ): PendingIntent {
        val intent = Intent(context, IncomingOfferActionReceiver::class.java).apply {
            this.action = action
            putOfferExtras(
                orderId = orderId,
                type = type,
                notificationType = notificationType,
                title = title,
                body = body,
                moduleType = moduleType,
                orderType = orderType,
                eventToken = eventToken,
                notificationId = notificationId,
                expiresAt = expiresAt,
            )
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
        moduleType: String?,
        orderType: String?,
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
            moduleType = moduleType,
            orderType = orderType,
            eventToken = eventToken,
            notificationId = notificationId,
            expiresAt = expiresAt,
            requestCode = requestCode,
        )
        runCatching {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, expiresAt, expireIntent)
        }.onFailure {
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, expiresAt, expireIntent)
        }
    }

    private fun Intent.putOfferExtras(
        orderId: String?,
        type: String?,
        notificationType: String?,
        title: String?,
        body: String?,
        moduleType: String?,
        orderType: String?,
        eventToken: String,
        notificationId: Int,
        expiresAt: Long,
    ) {
        putExtra(IncomingOfferContract.EXTRA_ORDER_ID, orderId)
        putExtra(IncomingOfferContract.EXTRA_TYPE, type)
        putExtra(IncomingOfferContract.EXTRA_NOTIFICATION_TYPE, notificationType)
        putExtra(IncomingOfferContract.EXTRA_TITLE, title)
        putExtra(IncomingOfferContract.EXTRA_BODY, body)
        putExtra(IncomingOfferContract.EXTRA_MODULE_TYPE, moduleType)
        putExtra(IncomingOfferContract.EXTRA_ORDER_TYPE, orderType)
        putExtra(IncomingOfferContract.EXTRA_EVENT_TOKEN, eventToken)
        putExtra(IncomingOfferContract.EXTRA_NOTIFICATION_ID, notificationId)
        putExtra(IncomingOfferContract.EXTRA_EXPIRES_AT, expiresAt)
    }

    private const val DEFAULT_EXPIRE_MS = 45_000L
}
