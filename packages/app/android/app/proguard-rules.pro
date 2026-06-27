# Flutter engine + embedding (reflection-loaded).
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase / Google Play services ship their own consumer rules; keep the
# generic metadata they rely on.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Play Core (deferred components) — referenced by the Flutter embedding even
# when unused; silence the warnings so R8 doesn't fail the build.
-dontwarn com.google.android.play.core.**

# flutter_local_notifications — reflection-loaded receivers + Gson serialisation.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type
-dontwarn com.google.gson.**
