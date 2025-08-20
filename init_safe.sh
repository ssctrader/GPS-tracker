#!/bin/bash
set -e

echo "[*] Tambahin struktur Android project kalau belum ada..."
mkdir -p app/src/main/java/com/example/gpstracker
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/mipmap-anydpi-v26
mkdir -p gradle/wrapper

# settings.gradle
cat > settings.gradle <<'EOF'
rootProject.name = "GPSTracker"
include ':app'
EOF

# build.gradle (root)
cat > build.gradle <<'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.3.2'
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

# gradle-wrapper.properties
cat > gradle/wrapper/gradle-wrapper.properties <<'EOF'
distributionUrl=https\://services.gradle.org/distributions/gradle-8.6-all.zip
EOF

# local.properties (hanya buat CI)
cat > local.properties <<'EOF'
sdk.dir=/usr/local/lib/android/sdk
EOF

# app/build.gradle
cat > app/build.gradle <<'EOF'
plugins {
    id 'com.android.application'
}

android {
    namespace "com.example.gpstracker"
    compileSdk 34

    defaultConfig {
        applicationId "com.example.gpstracker"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation 'com.google.android.gms:play-services-location:21.3.0'
}
EOF

# MainActivity.java
cat > app/src/main/java/com/example/gpstracker/MainActivity.java <<'EOF'
package com.example.gpstracker;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }
}
EOF

# AndroidManifest.xml
cat > app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.gpstracker">

    <application
        android:allowBackup="true"
        android:label="GPS Tracker"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">

        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

    </application>
</manifest>
EOF

# proguard rules
echo "" > app/proguard-rules.pro

# layout
cat > app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:gravity="center">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello GPS Tracker!"
        android:textSize="20sp"/>
</LinearLayout>
EOF

# Bitrise config
cat > bitrise.yml <<'EOF'
format_version: "11"
default_step_lib_source: "https://github.com/bitrise-io/bitrise-steplib.git"

workflows:
  primary:
    steps:
    - git-clone: {}
    - android-build:
        inputs:
        - project_location: "."
        - module: "app"
        - variant: "debug"
    - deploy-to-bitrise-io: {}
EOF

echo "[*] Semua file sudah dibuat/update ✔"
