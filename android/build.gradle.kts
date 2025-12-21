buildscript {
    var kotlinVersion = "1.9.24" // Update to Kotlin 1.9.0 or later
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.9.1") // Update to the latest version
        classpath("com.google.gms:google-services:4.4.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {

    plugins.whenPluginAdded {
        if (this is com.android.build.gradle.BasePlugin) {

            dependencies {
                add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
            }

            configurations.all {
                resolutionStrategy {
                    force("androidx.concurrent:concurrent-futures:1.2.0")
                }
            }
        }
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}