package com.sixamtech.sixam_mart_delivery_app

object IncomingOfferContract {
    const val ACTION_OFFER_OPEN = "com.sixamtech.sixam_mart_delivery_app.action.OFFER_OPEN"
    const val ACTION_OFFER_ACCEPT = "com.sixamtech.sixam_mart_delivery_app.action.OFFER_ACCEPT"
    const val ACTION_OFFER_DECLINE = "com.sixamtech.sixam_mart_delivery_app.action.OFFER_DECLINE"
    const val ACTION_OFFER_EXPIRE = "com.sixamtech.sixam_mart_delivery_app.action.OFFER_EXPIRE"

    const val EXTRA_ORDER_ID = "extra_order_id"
    const val EXTRA_TYPE = "extra_type"
    const val EXTRA_NOTIFICATION_TYPE = "extra_notification_type"
    const val EXTRA_TITLE = "extra_title"
    const val EXTRA_BODY = "extra_body"
    const val EXTRA_EVENT_TOKEN = "extra_event_token"
    const val EXTRA_NOTIFICATION_ID = "extra_notification_id"
    const val EXTRA_MODULE_TYPE = "extra_module_type"
    const val EXTRA_ORDER_TYPE = "extra_order_type"
    const val EXTRA_EXPIRES_AT = "extra_expires_at"

    const val SOURCE_ANDROID_RECEIVER = "android_receiver"
    const val SOURCE_ANDROID_NOTIFICATION = "android_notification"
    const val SOURCE_ANDROID_ACTIVITY = "android_activity"
}
