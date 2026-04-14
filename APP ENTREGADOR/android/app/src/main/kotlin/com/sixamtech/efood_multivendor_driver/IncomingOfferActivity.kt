package com.sixamtech.sixam_mart_delivery_app

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.core.app.NotificationManagerCompat
import java.lang.ref.WeakReference

class IncomingOfferActivity : Activity() {

    private lateinit var titleView: TextView
    private lateinit var offerTypeView: TextView
    private lateinit var offerIdView: TextView
    private lateinit var offerBodyView: TextView
    private lateinit var offerMetaView: TextView
    private lateinit var expireView: TextView
    private lateinit var acceptButton: Button
    private lateinit var declineButton: Button

    private val uiHandler = Handler(Looper.getMainLooper())
    private var expiryRunnable: Runnable? = null

    private var orderId: String? = null
    private var eventToken: String? = null
    private var type: String? = null
    private var notificationType: String? = null
    private var moduleType: String? = null
    private var orderType: String? = null
    private var expiresAt: Long = 0L
    private var notificationId: Int? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_incoming_offer)
        configureAggressiveWindowMode()
        bindViews()
        applyIntent(intent, fromNewIntent = false)
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        applyIntent(intent, fromNewIntent = true)
    }

    override fun onResume() {
        super.onResume()
        if (isExpired()) {
            closeAndEmitExpire(reason = "expired_on_resume")
        }
    }

    override fun onDestroy() {
        clearExpiryTimer()
        super.onDestroy()
    }

    private fun bindViews() {
        titleView = findViewById(R.id.offerTitle)
        offerTypeView = findViewById(R.id.offerType)
        offerIdView = findViewById(R.id.offerId)
        offerBodyView = findViewById(R.id.offerBody)
        offerMetaView = findViewById(R.id.offerMeta)
        expireView = findViewById(R.id.offerExpireState)
        acceptButton = findViewById(R.id.offerAcceptButton)
        declineButton = findViewById(R.id.offerDeclineButton)

        acceptButton.setOnClickListener { emitActionAndClose(IncomingOfferBridge.OFFER_ACCEPT_TAPPED) }
        declineButton.setOnClickListener { emitActionAndClose(IncomingOfferBridge.OFFER_DECLINE_TAPPED) }
        findViewById<View>(R.id.offerCloseButton).setOnClickListener {
            emitActionAndClose(IncomingOfferBridge.OFFER_DECLINE_TAPPED)
        }
    }

    private fun applyIntent(rawIntent: Intent?, fromNewIntent: Boolean) {
        val incomingIntent = rawIntent ?: return
        orderId = incomingIntent.getStringExtra(IncomingOfferContract.EXTRA_ORDER_ID)
        eventToken = incomingIntent.getStringExtra(IncomingOfferContract.EXTRA_EVENT_TOKEN)
        type = incomingIntent.getStringExtra(IncomingOfferContract.EXTRA_TYPE)
        notificationType = incomingIntent.getStringExtra(IncomingOfferContract.EXTRA_NOTIFICATION_TYPE)
        moduleType = incomingIntent.getStringExtra(IncomingOfferContract.EXTRA_MODULE_TYPE)
        orderType = incomingIntent.getStringExtra(IncomingOfferContract.EXTRA_ORDER_TYPE)
        notificationId = incomingIntent.getIntExtra(IncomingOfferContract.EXTRA_NOTIFICATION_ID, 0).takeIf { it > 0 }
        expiresAt = incomingIntent.getLongExtra(IncomingOfferContract.EXTRA_EXPIRES_AT, 0L)

        val title = incomingIntent.getStringExtra(IncomingOfferContract.EXTRA_TITLE)?.takeIf { it.isNotBlank() }
            ?: defaultTitle(type, moduleType)
        val body = incomingIntent.getStringExtra(IncomingOfferContract.EXTRA_BODY)?.takeIf { it.isNotBlank() }
            ?: "Revise os detalhes no app para confirmar o contexto da oferta."

        if (orderId.isNullOrBlank() || resolveOfferType().isBlank()) {
            finishSafely()
            return
        }

        IncomingOfferNotificationHelper.markOfferAsDisplayed(orderId)
        activeActivity.set(WeakReference(this))

        offerTypeView.text = "Tipo: ${resolveOfferType()}"
        offerIdView.text = "Oferta #${orderId}"
        titleView.text = title
        offerBodyView.text = body
        offerMetaView.text = buildMetaText()

        scheduleExpiry()
        notificationId?.let { NotificationManagerCompat.from(this).cancel(it) }

        IncomingOfferBridge.emitOfferEvent(
            event = IncomingOfferBridge.OFFER_OPENED,
            source = IncomingOfferContract.SOURCE_ANDROID_ACTIVITY,
            type = type,
            orderId = orderId,
            notificationType = notificationType,
            payload = payloadForBridge(nativeAction = if (fromNewIntent) "activity_refresh" else "activity_open"),
        )
    }

    private fun emitActionAndClose(event: String) {
        IncomingOfferBridge.emitOfferEvent(
            event = event,
            source = IncomingOfferContract.SOURCE_ANDROID_ACTIVITY,
            type = type,
            orderId = orderId,
            notificationType = notificationType,
            payload = payloadForBridge(nativeAction = event),
        )
        finishSafely()
    }

    private fun closeAndEmitExpire(reason: String) {
        IncomingOfferBridge.emitOfferEvent(
            event = IncomingOfferBridge.OFFER_EXPIRED,
            source = IncomingOfferContract.SOURCE_ANDROID_ACTIVITY,
            type = type,
            orderId = orderId,
            notificationType = notificationType,
            payload = payloadForBridge(nativeAction = reason),
        )
        finishSafely()
    }

    private fun payloadForBridge(nativeAction: String): Map<String, Any?> = mapOf(
        "order_id" to orderId,
        "type" to type,
        "notification_type" to notificationType,
        "module_type" to moduleType,
        "order_type" to orderType,
        "event_token" to eventToken,
        "notification_id" to notificationId,
        "expires_at" to expiresAt,
        "native_action" to nativeAction,
        "native_takeover" to true,
    )

    private fun defaultTitle(type: String?, moduleType: String?): String {
        return when {
            moduleType == "ride" || type == "assign" -> "Nova corrida disponível"
            else -> "Nova entrega disponível"
        }
    }

    private fun resolveOfferType(): String {
        val normalized = type?.takeIf { it.isNotBlank() }
            ?: notificationType?.takeIf { it.isNotBlank() }
            ?: ""
        return normalized
    }

    private fun buildMetaText(): String {
        val moduleText = moduleType?.takeIf { it.isNotBlank() } ?: "não informado"
        val orderTypeText = orderType?.takeIf { it.isNotBlank() } ?: "não informado"
        return "Módulo: $moduleText   •   Order type: $orderTypeText"
    }

    private fun configureAggressiveWindowMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }

        @Suppress("DEPRECATION")
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON,
        )
    }

    private fun scheduleExpiry() {
        clearExpiryTimer()
        if (expiresAt <= 0L) {
            expireView.text = "Expira em breve"
            return
        }

        val remaining = expiresAt - System.currentTimeMillis()
        if (remaining <= 0L) {
            closeAndEmitExpire(reason = "expired_on_open")
            return
        }

        expireView.text = "Expira em ${(remaining / 1000L).coerceAtLeast(1L)}s"
        expiryRunnable = Runnable {
            closeAndEmitExpire(reason = "expired_timer")
        }.also { runnable ->
            uiHandler.postDelayed(runnable, remaining)
        }
    }

    private fun clearExpiryTimer() {
        expiryRunnable?.let { uiHandler.removeCallbacks(it) }
        expiryRunnable = null
    }

    private fun isExpired(): Boolean = expiresAt > 0L && System.currentTimeMillis() >= expiresAt

    private fun finishSafely() {
        clearExpiryTimer()
        if (activeActivity.get()?.get() == this) {
            activeActivity.set(null)
        }
        finish()
    }

    companion object {
        private val activeActivity = java.util.concurrent.atomic.AtomicReference<WeakReference<IncomingOfferActivity>?>(null)

        @JvmStatic
        fun closeIfMatching(orderId: String?) {
            val current = activeActivity.get()?.get() ?: return
            if (orderId.isNullOrBlank() || current.orderId == orderId) {
                current.finishSafely()
            }
        }
    }
}
