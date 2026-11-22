allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // Before evaluationDependsOn: that call evaluates :app immediately.
    afterEvaluate {
        if (name == "app") return@afterEvaluate
        val kotlinTask = tasks.findByName("compileDebugKotlin") ?: return@afterEvaluate
        val kotlinOptions = kotlinTask.javaClass.methods
            .firstOrNull { it.name == "getKotlinOptions" }
            ?.invoke(kotlinTask)
        val raw = kotlinOptions?.javaClass?.methods
            ?.firstOrNull { it.name == "getJvmTarget" }
            ?.invoke(kotlinOptions) as? String
        val level = when (raw) {
            "1.8", "8" -> "1.8"
            "11" -> "11"
            "21" -> "21"
            else -> "17"
        }
        val javaVersion = when (level) {
            "1.8" -> JavaVersion.VERSION_1_8
            "11" -> JavaVersion.VERSION_11
            "21" -> JavaVersion.VERSION_21
            else -> JavaVersion.VERSION_17
        }
        val androidExt = extensions.findByName("android")
        val compileOptions = androidExt?.javaClass?.methods
            ?.firstOrNull { it.name == "getCompileOptions" }
            ?.invoke(androidExt)
        compileOptions?.javaClass?.methods
            ?.firstOrNull { it.name == "setSourceCompatibility" }
            ?.invoke(compileOptions, javaVersion)
        compileOptions?.javaClass?.methods
            ?.firstOrNull { it.name == "setTargetCompatibility" }
            ?.invoke(compileOptions, javaVersion)
        tasks.withType(org.gradle.api.tasks.compile.JavaCompile::class.java).configureEach {
            sourceCompatibility = level
            targetCompatibility = level
        }
    }
    project.evaluationDependsOn(":app")
}

// AGP 8.11 requires namespace. Some older plugins still only declare package in the manifest.
subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.getByName("android")
        val current = androidExt.javaClass.methods
            .firstOrNull { it.name == "getNamespace" }
            ?.invoke(androidExt) as? String
        if (current.isNullOrEmpty()) {
            val manifest = file("src/main/AndroidManifest.xml")
            val pkg = Regex("""package="([^"]+)"""")
                .find(manifest.readText())
                ?.groupValues
                ?.get(1)
            if (pkg != null) {
                androidExt.javaClass.methods
                    .firstOrNull { it.name == "setNamespace" }
                    ?.invoke(androidExt, pkg)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
