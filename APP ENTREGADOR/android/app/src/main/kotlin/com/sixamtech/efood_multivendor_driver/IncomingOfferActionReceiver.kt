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

        when (action) {
            IncomingOfferContract.ACTION_OFFER_OPEN -> {
                openApp(context, payload)
                emitBridgeEvent(
                    event = IncomingOfferBridge.OFFER_OPENED,
                    payload = payload,
                    orderId = orderId,
                    type = type,
                    notificationType = notificationType,
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
            }
            IncomingOfferContract.ACTION_OFFER_DECLINE -> {
                emitBridgeEvent(
                    event = IncomingOfferBridge.OFFER_DECLINE_TAPPED,
                    payload = payload,
                    orderId = orderId,
                    type = type,
                    notificationType = notificationType,
                )
            }
            IncomingOfferContract.ACTION_OFFER_EXPIRE -> {
                emitBridgeEvent(
                    event = IncomingOfferBridge.OFFER_EXPIRED,
                    payload = payload,
                    orderId = orderId,
                    type = type,
                    notificationType = notificationType,
                )
            }
            else -> return
        }

        notificationId?.let { NotificationManagerCompat.from(context).cancel(it) }
    }

    private fun openApp(context: Context, payload: Map<String, Any?>) {
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("order_id", payload["order_id"]?.toString())
            putExtra("type", payload["type"]?.toString())
            putExtra("notification_type", payload["notification_type"]?.toString())
            putExtra("offer_event_token", payload["event_token"]?.toString())
        }
        context.startActivity(launchIntent)
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
            "event_token" to intent.getStringExtra(IncomingOfferContract.EXTRA_EVENT_TOKEN),
            "notification_id" to intent.getIntExtra(IncomingOfferContract.EXTRA_NOTIFICATION_ID, 0),
            "native_action" to intent.action,
        )
    }
}
