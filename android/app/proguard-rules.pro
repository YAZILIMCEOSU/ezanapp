# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# just_audio / audio_service (arka planda çalma)
-keep class com.ryanheise.** { *; }
-keep class androidx.media.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Firebase / Crashlytics
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Gson / Supabase / Kotlin
-keep class com.google.gson.** { *; }
-dontwarn sun.misc.**
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Vakit verisi JSON modelleri (reflection ile çözülürse)
-keep class com.yazilimceosu.ezanai.** { *; }

# flutter_secure_storage / Tink şifreleme
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

