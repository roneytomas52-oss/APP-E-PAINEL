package com.sixamtech.sixam_mart_delivery_app

import android.content.Intent
import android.os.Bundle
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import java.util.concurrent.atomic.AtomicReference

class IncomingOfferBridge(
    messenger: BinaryMessenger,
    private val appContext: android.content.Context,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val commandChannel = MethodChannel(messenger, COMMAND_CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)
    private var eventSink: EventChannel.EventSink? = null

    init {
        activeBridge.set(this)
        commandChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "bridgeReady" -> {
                flushPendingEvents()
                result.success(true)
            }
            "getPendingEvents" -> {
                result.success(drainPendingEvents())
            }
            "showIncomingOfferNotification" -> {
                val argumentMap = call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()
                IncomingOfferNotificationHelper.showIncomingOfferNotification(
                    context = appContext,
                    orderId = argumentMap["order_id"]?.toString(),
                    type = argumentMap["type"]?.toString(),
                    notificationType = argumentMap["notification_type"]?.toString(),
                    title = argumentMap["title"]?.toString(),
                    body = argumentMap["body"]?.toString(),
                    moduleType = argumentMap["module_type"]?.toString(),
                    orderType = argumentMap["order_type"]?.toString(),
                    expiresInMs = (argumentMap["expires_in_ms"] as? Number)?.toLong() ?: 45_000L,
                )
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        flushPendingEvents()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun handleIntent(intent: Intent?, source: String = "android_intent") {
        val extras = intent?.extras ?: return
        val payload = bundleToMap(extras)

        if (!payload.containsKey("order_id") && !payload.containsKey("type") && !payload.containsKey("notification_type")) {
            return
        }

        enqueueEvent(
            buildEvent(
                event = APP_REOPENED_WITH_OFFER,
                source = source,
                type = payload["type"]?.toString() ?: "unknown",
                orderId = payload["order_id"]?.toString(),
                notificationType = payload["notification_type"]?.toString() ?: payload["type"]?.toString(),
                payload = payload,
            ),
        )
    }

    fun emitOfferEvent(
        event: String,
        source: String,
        type: String?,
        orderId: String?,
        notificationType: String?,
        payload: Map<String, Any?> = emptyMap(),
    ) {
        enqueueEvent(
            buildEvent(
                event = event,
                source = source,
                type = type ?: "unknown",
                orderId = orderId,
                notificationType = notificationType,
                payload = payload,
            ),
        )
    }

    private fun enqueueEvent(event: Map<String, Any?>) {
        IncomingOfferLog.i(
            stage = event["event"]?.toString() ?: "offer_event",
            source = event["source"]?.toString(),
            orderId = event["order_id"]?.toString(),
            eventId = event["event_id"]?.toString(),
            eventToken = (event["payload"] as? Map<*, *>)?.get("event_token")?.toString(),
            moduleType = (event["payload"] as? Map<*, *>)?.get("module_type")?.toString(),
            type = event["type"]?.toString(),
            message = "bridge_event_enqueued",
        )
        val sink = eventSink
        if (sink == null) {
            synchronized(pendingEvents) {
                pendingEvents.add(event)
            }
        } else {
            sink.success(event)
        }
    }

    private fun flushPendingEvents() {
        val sink = eventSink ?: return
        val eventsToEmit = drainPendingEvents()
        for (event in eventsToEmit) {
            sink.success(event)
        }
    }

    private fun drainPendingEvents(): List<Map<String, Any?>> {
        synchronized(pendingEvents) {
            if (pendingEvents.isEmpty()) return emptyList()
            val snapshot = pendingEvents.toList()
            pendingEvents.clear()
            return snapshot
        }
    }


    private fun bundleToMap(bundle: Bundle): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        for (key in bundle.keySet()) {
            map[key] = bundle.get(key)
        }
        return map
    }

    companion object {
        const val COMMAND_CHANNEL = "com.sixamtech/incoming_offer_bridge/commands"
        const val EVENT_CHANNEL = "com.sixamtech/incoming_offer_bridge/events"

        const val BRIDGE_VERSION = 1
        const val OFFER_OPENED = "offer_opened"
        const val OFFER_ACCEPT_TAPPED = "offer_accept_tapped"
        const val OFFER_DECLINE_TAPPED = "offer_decline_tapped"
        const val OFFER_EXPIRED = "offer_expired"
        const val APP_REOPENED_WITH_OFFER = "app_reopened_with_offer"

        private val pendingEvents = mutableListOf<Map<String, Any?>>()
        private val activeBridge = AtomicReference<IncomingOfferBridge?>(null)

        @JvmStatic
        fun emitOfferEvent(
            event: String,
            source: String,
            type: String?,
            orderId: String?,
            notificationType: String?,
            payload: Map<String, Any?> = emptyMap(),
        ) {
            val bridge = activeBridge.get()
            if (bridge != null) {
                bridge.emitOfferEvent(event, source, type, orderId, notificationType, payload)
                return
            }

            synchronized(pendingEvents) {
                pendingEvents.add(
                    buildEvent(
                        event = event,
                        source = source,
                        type = type ?: "unknown",
                        orderId = orderId,
                        notificationType = notificationType,
                        payload = payload,
                    ),
                )
            }
        }

        private fun buildEvent(
            event: String,
            source: String,
            type: String,
            orderId: String?,
            notificationType: String?,
            payload: Map<String, Any?>,
        ): Map<String, Any?> {
            val payloadToken = payload["event_token"]?.toString()?.takeIf { it.isNotBlank() }
            val stableEventId = payloadToken?.let { token ->
                "${source}_${event}_${orderId ?: "no_order"}_$token"
            } ?: UUID.randomUUID().toString()
            return mapOf(
                "version" to BRIDGE_VERSION,
                "event" to event,
                "source" to source,
                "type" to type,
                "order_id" to orderId,
                "notification_type" to notificationType,
                "timestamp" to System.currentTimeMillis(),
                "event_id" to stableEventId,
                "payload" to payload,
            )
        }
    }
}
