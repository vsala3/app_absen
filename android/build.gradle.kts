allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val rootProjectBuildDir: Directory = project.layout.buildDirectory.get()
tasks.register<Delete>("clean") {
    delete(rootProjectBuildDir)
}

// Logic pemindahan folder build agar cache rapi di Flutter
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}