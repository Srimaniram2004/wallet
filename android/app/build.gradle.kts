plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {

    namespace = "com.example.wallet_app"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = flutter.ndkVersion

    compileOptions {

        sourceCompatibility = JavaVersion.VERSION_17

        targetCompatibility = JavaVersion.VERSION_17

        // FIX NOTIFICATION ERROR
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {

        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {

        applicationId = "com.example.wallet_app"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }

    buildTypes {

        release {

            signingConfig =
                signingConfigs.getByName("debug")
        }
    }
}

dependencies {

    // REQUIRED FOR flutter_local_notifications
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.2"
    )
}

flutter {

    source = "../.."
}   