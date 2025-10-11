plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bed_app_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Prefer Java 17 with modern AGP/Flutter
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.bed_app_1"
        minSdk = maxOf(21, flutter.minSdkVersion)   // ensure at least 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Firebase manifest placeholders
        manifestPlaceholders["firebaseAnalyticsCollectionEnabled"] = "true"
        manifestPlaceholders["firebaseCrashlyticsCollectionEnabled"] = "true"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Satisfies flutter_local_notifications requirement
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
