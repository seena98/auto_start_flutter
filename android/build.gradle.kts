group = "co.techFlow.auto_start_flutter"
version = "1.0"

plugins {
    id("com.android.library")
}

android {
    namespace = "co.techFlow.auto_start_flutter"
    compileSdk = 35

    defaultConfig {
        minSdk = 16
    }

    lint {
        disable.add("InvalidPackage")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    testOptions {
        unitTests.all {
            it.testLogging {
                events("passed", "skipped", "failed", "standardOut", "standardError")
                showStandardStreams = true
            }
            it.outputs.upToDateWhen { false }
        }
    }
}

dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}
