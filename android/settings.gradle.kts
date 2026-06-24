pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val propertiesFile = file("local.properties")
        if (propertiesFile.exists()) {
            propertiesFile.inputStream().use { properties.load(it) }
        }
        val flutterSdkPath = properties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")
        require(flutterSdkPath != null) { "Flutter SDK not found. Define location with flutter.sdk in local.properties or with FLUTTER_ROOT environment variable." }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Diperbarui ke 8.6.0 sesuai batas minimum aman dari Flutter SDK Anda
    id("com.android.application") version "8.6.0" apply false
    // Diperbarui ke 1.9.24 yang sangat stabil berpasangan dengan AGP 8.6.0
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}

include(":app")