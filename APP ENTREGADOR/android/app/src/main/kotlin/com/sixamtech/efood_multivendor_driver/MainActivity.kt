package com.sixamtech.sixam_mart_delivery_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var incomingOfferBridge: IncomingOfferBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_RETAIN_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendToBackground" -> {
                        moveTaskToBack(true)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        incomingOfferBridge = IncomingOfferBridge(flutterEngine.dartExecutor.binaryMessenger)
        incomingOfferBridge?.handleIntent(intent, source = "activity_launch")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        incomingOfferBridge?.handleIntent(intent, source = "activity_reopen")
    }

    companion object {
        private const val APP_RETAIN_CHANNEL = "com.sixamtech/app_retain"
    }
}
