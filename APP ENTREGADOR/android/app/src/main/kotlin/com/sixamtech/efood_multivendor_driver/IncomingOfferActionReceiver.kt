package com.sixamtech.sixam_mart_delivery_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat

class IncomingOfferActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        val payload = extractPayload(intent)
        val orderId = payload["order_id"]?.toString()
        val type = payload["type"]?.toString()
        val notificationType = payload["notification_type"]?.toString()
        val notificationId = payload["notification_id"]?.toString()?.toIntOrNull()
        val eventToken = payload["event_token"]?.toString() ?: ""
        val expiresAt = payload["expires_at"]?.toString()?.toLongOrNull() ?: 0L

        when (action) {
            IncomingOfferContract.ACTION_OFFER_OPEN -> {
                IncomingOfferNotificationHelper.maybeLaunchIncomingOfferActivity(
                    context = context,
                    orderId = orderId,
                    type = type,
                    notificationType = notificationType,
                    title = payload["title"]?.toString(),
                    body = payload["body"]?.toString(),
                    moduleType = payload["module_type"]?.toString(),
                    orderType = payload["order_type"]?.toString(),
                    eventToken = eventToken,
                    notificationId = notificationId ?: IncomingOfferNotificationHelper.resolveNotificationId(orderId),
                    expiresAt = expiresAt,
                    force = true,
                )
            }
            IncomingOfferContract.ACTION_OFFER_ACCEPT -> {
                emitBridgeEvent(
                    event = IncomingOfferBridge.OFFER_ACCEPT_TAPPED,
                    payload = payload,
                    orderId = orderId,
                    type = type,
                    notificationType = notificationType,
                )
                IncomingOfferActivity.closeIfMatching(orderId)
            }
            IncomingOfferContract.ACTION_OFFER_DECLINE -> {
                emitBridgeEvent(
                    event = IncomingOfferBridge.OFFER_DECLINE_TAPPED,
                    payload = payload,
                    orderId = orderId,
                    type = type,
                    notificationType = notificationType,
                )
                IncomingOfferActivity.closeIfMatching(orderId)
            }
            IncomingOfferContract.ACTION_OFFER_EXPIRE -> {
                emitBridgeEvent(
                    event = IncomingOfferBridge.OFFER_EXPIRED,
                    payload = payload,
                    orderId = orderId,
                    type = type,
                    notificationType = notificationType,
                )
                IncomingOfferActivity.closeIfMatching(orderId)
            }
            else -> return
        }

        notificationId?.let { NotificationManagerCompat.from(context).cancel(it) }
    }

    private fun emitBridgeEvent(
        event: String,
        payload: Map<String, Any?>,
        orderId: String?,
        type: String?,
        notificationType: String?,
    ) {
        IncomingOfferBridge.emitOfferEvent(
            event = event,
            source = IncomingOfferContract.SOURCE_ANDROID_RECEIVER,
            type = type,
            orderId = orderId,
            notificationType = notificationType,
            payload = payload,
        )
    }

    private fun extractPayload(intent: Intent): Map<String, Any?> {
        return mapOf(
            "order_id" to intent.getStringExtra(IncomingOfferContract.EXTRA_ORDER_ID),
            "type" to intent.getStringExtra(IncomingOfferContract.EXTRA_TYPE),
            "notification_type" to intent.getStringExtra(IncomingOfferContract.EXTRA_NOTIFICATION_TYPE),
            "title" to intent.getStringExtra(IncomingOfferContract.EXTRA_TITLE),
            "body" to intent.getStringExtra(IncomingOfferContract.EXTRA_BODY),
            "module_type" to intent.getStringExtra(IncomingOfferContract.EXTRA_MODULE_TYPE),
            "order_type" to intent.getStringExtra(IncomingOfferContract.EXTRA_ORDER_TYPE),
            "event_token" to intent.getStringExtra(IncomingOfferContract.EXTRA_EVENT_TOKEN),
            "notification_id" to intent.getIntExtra(IncomingOfferContract.EXTRA_NOTIFICATION_ID, 0),
            "expires_at" to intent.getLongExtra(IncomingOfferContract.EXTRA_EXPIRES_AT, 0L),
            "native_action" to intent.action,
        )
    }
}
