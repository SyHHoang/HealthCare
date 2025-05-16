plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = flutter.compileSdkVersion.toInt()  // Chuyển sang Int
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion.toInt()  // Chuyển sang Int
        versionCode = flutter.versionCode?.toInt() ?: 1  // Xử lý null safety
        versionName = flutter.versionName ?: "1.0.0"     // Xử lý null safety
        
        // Thêm cấu hình buildConfig
        buildConfigField("String", "FLUTTER_VERSION", "\"${flutter.versionName}\"")
    }

    buildTypes {
        release {
            isMinifyEnabled = false  // Kotlin DSL style
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
        
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
    }

    // Bật viewBinding nếu cần
    buildFeatures {
        viewBinding = true
        buildConfig = true
    }

    // Cấu hình lint (bỏ qua lỗi AudioSwitch nếu cần)
    lint {
        disable.add("NewApi")
        abortOnError = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")  // Thêm dependency nếu cần
}