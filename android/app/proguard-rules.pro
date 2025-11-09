-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class com.google.firebase.messaging.RemoteMessage { *; }
-keep class * extends java.util.ListResourceBundle { *; }
-keep public class * extends android.content.BroadcastReceiver

# Keep Huawei HMS and related
-keep class com.huawei.** { *; }
-dontwarn com.huawei.**
-dontnote com.huawei.**
-dontwarn com.huawei.android.os.BuildEx$VERSION
-dontwarn com.huawei.hms.support.hianalytics.**
-dontwarn com.huawei.hms.utils.HMSBIInitializer
-dontwarn com.huawei.libcore.io.**

# BouncyCastle used by Huawei secure utils
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# ML/Camera (if used via reflection)
-keep class androidx.camera.** { *; }
-keep class com.google.mlkit.** { *; }
-dontwarn androidx.camera.**
-dontwarn com.google.mlkit.**

# Flutter plugin entry points
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Flutter deferred components and Google Play Core
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep annotations
-keepattributes *Annotation*