// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle plugin is not required for signingReport to produce SHA,
    // so we avoid referencing the 'flutter' extension here.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.study_mate"

    // Use explicit values so the Kotlin DSL can compile without the 'flutter' extension.
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // applicationId should match your Firebase app package (keep your value)
        applicationId = "com.example.study_mate"

        // conservative defaults (you can change these later to match your flutter project settings)
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // keep using debug signing config for now so signingReport works
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    // Keep a minimal placeholder so the Kotlin parser sees this block — it's ignored by Gradle if plugin doesn't provide it.
    // If this causes errors, remove these two lines.
    // source = "../.."
}

// Apply Google services plugin for processing google-services.json
apply(plugin = "com.google.gms.google-services")
