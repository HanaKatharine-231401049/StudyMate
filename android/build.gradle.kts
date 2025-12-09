// android/build.gradle.kts (use this exact content)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Kotlin DSL: use function call with double quotes
        classpath("com.google.gms:google-services:4.3.15")
    }
}

plugins {
    // keep this empty for Flutter root; Flutter plugin is applied in app module
}

// repositories for all projects
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// move build outputs out of android folder (optional Flutter optimization)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ensure app module is evaluated
subprojects {
    project.evaluationDependsOn(":app")
}

// clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
