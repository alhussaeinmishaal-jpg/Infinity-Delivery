plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // تفعيل إضافة Google Services للربط مع Firebase
    id("com.google.gms.google-services")
}

android {
    // تأكد أن هذا الاسم يطابق المسجل في Firebase Console
    namespace = "com.example.infinity_delivery" 
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        // توحيد إصدار الجافا لحل مشكلة التوافق
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        // توحيد إصدار JVM Target ليتوافق مع الجافا
        jvmTarget = "1.8"
    }

    defaultConfig {
        // معرف التطبيق الخاص بـ Infinity Delivery
        applicationId = "com.example.infinity_delivery"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // إعدادات التوقيع (Signing) للنسخة النهائية
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // هنا يتم إضافة أي مكتبات أندرويد أصلية إذا احتجت لها مستقبلاً
}