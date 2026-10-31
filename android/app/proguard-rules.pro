# Flutter & JNI / Pigeon eklenti köprüleri
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class dev.flutter.** { *; }
-keep class dev.fluttercommunity.** { *; }
-keep class plus.fluttercommunity.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keep class com.benjaminabel.vibration.** { *; }
-keep class com.llfbandit.app_links.** { *; }
-dontwarn io.flutter.embedding.**

# Dart JNI (jnigen / shared_preferences_android 2.5+ ve diğer JNI eklentileri)
-keep class com.github.dart_lang.jni.** { *; }
-dontwarn com.github.dart_lang.jni.**

# Kotlin stdlib & Coroutines (JNI üzerinden çağrılan suspend metotların Continuation imzalarının korunması için zorunlu)
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# AndroidX DataStore / SharedPreferences
-keep class androidx.datastore.** { *; }
-dontwarn androidx.datastore.**

# Imza, Jenerik ve Anotasyon öznitelikleri
-keepattributes Signature,InnerClasses,EnclosingMethod,Exceptions,SourceFile,LineNumberTable,*Annotation*

# just_audio / audio_service (arka planda çalma)
-keep class com.ryanheise.** { *; }
-keep class androidx.media.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Firebase / Crashlytics
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


