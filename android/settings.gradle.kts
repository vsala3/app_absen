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
    id("com.android.application") version "8.1.0" apply false
    // Menggunakan Kotlin versi stabil yang aman untuk Gradle 8.1.0 bawaan Flutter Anda
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")