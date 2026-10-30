# flutter_local_notifications: Gson serialization for scheduled notifications + receivers.
# Without these, release builds (if minify is ever enabled) drop scheduled alarms.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Gson (plugin dependency; R8 may strip TypeToken otherwise).
-keepattributes Signature
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
