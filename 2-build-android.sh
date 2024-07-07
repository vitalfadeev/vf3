#!/bin/bash
LDC_DIR=~/bin/LDC
NDK_DIR=/media/vf/C/NDK/android-ndk-r26d/

LDC=~/LDC_DIR/bin/ldc2

PATH=LDC_DIR/bin/:$PATH

# Build D for Android
# https://wiki.dlang.org/Build_D_for_Android#Prerequisites
# native ELF TLS (thread-local storage), which was introduced in API level 29 (Android v10).

# On android
# 1. Android SSH server
## 2. Termux for Android (https://www.apkmirror.com/apk/fredrik-fornwall/termux/) (https://f-droid.org/packages/com.termux/)

# On Linux
# 1. LDC (https://github.com/ldc-developers/ldc/releases)
# 2. NDK (https://developer.android.com/ndk/downloads)
# 3. scp (apt install openssh)

#
# Load this link in your browser and download the file otherwise 
curl -L -O https://raw.githubusercontent.com/dlang/dmd/master/samples/sieve.d

exit 1

# Cross-compile & -link to ARMv7-A (on any host)
ldc2 -mtriple=armv7a--linux-androideabi29 sieve.d

# Cross-compile & -link to AArch64 (on any host)
ldc2 -mtriple=aarch64--linux-android29 sieve.d

# Compile & link natively in Termux
ldc2 sieve.d

#
apt install openssh
cd
scp jo@192.168.1.37:sieve .
chmod 700 sieve

#
./sieve 1000000

# OpenGL ES 1.0 D
#
sudo apt-get install git # In Termux, apt install git
git clone https://github.com/Diewi/android.git
cd android

# Alternatively, without git:
curl -L -O https://github.com/Diewi/android/archive/build.zip
unzip build.zip
cd android-build

#
cd samples/native-activity

ldc2 -I../.. jni/main.d ../../android/sensor.d ../../android_native_app_glue.d \
     -shared -of=libs/arm64-v8a/libnative-activity.so \ # or `libs/armeabi-v7a/...` for 32-bit ARM
     -L-soname -Llibnative-activity.so \
     -mtriple=aarch64--linux-android29 # only for cross-compilation; use `armv7a--linux-androideabi29` for 32-bit ARM
     # possibly needed: -L-llog -L-landroid -L-lEGL -L-lGLESv1_CM

# Go to Settings->Security on your Android device and allow installation of apps from unknown sources

#
# apt install aapt apksigner
#
cd samples/native-activity
aapt package -M AndroidManifest.xml -S res -F NativeActivity-debug-unsigned.apk
APK_DIR=armeabi-v7a # or `arm64-v8a` for 64-bit ARM
aapt add NativeActivity-debug-unsigned.apk libs/$APK_DIR/libnative-activity.so

aapt list NativeActivity-debug-unsigned.apk

apksigner debug.ks NativeActivity-debug-unsigned.apk NativeActivity-debug.apk

apt install openssl-tool

openssl req -x509 -nodes -newkey rsa:2048 -keyout key.pem -out apk.cert

mkdir unpack
cd unpack/
unzip ../NativeActivity-debug.apk

cd META-INF/
openssl smime -sign -md sha1 -binary -noattr -in CERT.SF -out CERT.RSA -outform der -inkey ../../key.pem -signer ../../apk.cert

cd ..
aapt remove ../NativeActivity-debug.apk META-INF/CERT.RSA
aapt add ../NativeActivity-debug.apk META-INF/CERT.RSA

cd ..
cp NativeActivity-debug.apk /sdcard/Download/

