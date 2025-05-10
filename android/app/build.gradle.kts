plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // The Flutter Gradle Plugin must be applied after Android and Kotlin.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.smdpro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // ✅ Fixed NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.smdpro"
        minSdk = 23  // ✅ Updated minSdkVersion (Required for Firebase Auth)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.11.0"))

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Add the dependencies for any other Firebase products
    // Example: Firestore, Auth, Storage, etc.
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
}

flutter {
    source = "../.."
}
