# Flutter/R8 Obfuscation Rules
# ============================
#
# This file contains ProGuard/R8 rules to prevent code removal
# and ensure the app works correctly with obfuscation enabled.
#
# IMPORTANT: Keep these rules in sync with your app's dependencies

# Flutter framework
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Generated plugin classes
-keep class * extends io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep @JsonSerializable classes
-keep class * extends com.google.gson.annotations.SerializedName { *; }

# Dio/Network
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepattributes Signature
-keepattributes *Annotation*

# crypto package (for BIP39)
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Keep method signatures for reflection
-keepattributes InnerClasses,EnclosingMethod

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Keep crash reporter classes
-keep class com.google.firebase.crashlytics.** { *; }

# libsignal (if used)
-keep class org.signal.** { *; }

# Secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Socket.io
-keep class io.socket.** { *; }

# MongoDB
-keep class com.mongodb.** { *; }

# Keep model classes (for JSON serialization)
-keep class com.example.chat_app.features.**.models.** { *; }

# Riverpod
-keep class riverpod.** { *; }
-keep class * extends riverpod.Viewer { *; }
