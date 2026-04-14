package com.sixamtech.sixam_mart_delivery_app

import android.util.Log

object IncomingOfferLog {
    private const val TAG = "IncomingOfferTakeover"

    fun i(
        stage: String,
        source: String? = null,
        orderId: String? = null,
        eventId: String? = null,
        eventToken: String? = null,
        moduleType: String? = null,
        type: String? = null,
        message: String? = null,
    ) {
        val fields = linkedMapOf<String, String>()
        fields["stage"] = stage
        source?.takeIf { it.isNotBlank() }?.let { fields["source"] = it }
        orderId?.takeIf { it.isNotBlank() }?.let { fields["order_id"] = it }
        eventId?.takeIf { it.isNotBlank() }?.let { fields["event_id"] = it }
        eventToken?.takeIf { it.isNotBlank() }?.let { fields["event_token"] = it }
        moduleType?.takeIf { it.isNotBlank() }?.let { fields["module_type"] = it }
        type?.takeIf { it.isNotBlank() }?.let { fields["type"] = it }
        message?.takeIf { it.isNotBlank() }?.let { fields["message"] = it }

        Log.i(TAG, fields.entries.joinToString(separator = " | ") { "${it.key}=${it.value}" })
    }
}
