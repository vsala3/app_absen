allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    configurations.all {
        resolutionStrategy {
            force("com.pichillilorenzo.flutter_inappwebview:flutter_inappwebview_android:1.3.0")
        }
    }
}

// ... (Sisa kode atas biarkan tetap sama)

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        // Tambahan opsi untuk membabat warning metadata jika ada library bandel
        freeCompilerArgs.add("-Xskip-metadata-version-check")
    }
}

flutter {
    source = "../.."
}
