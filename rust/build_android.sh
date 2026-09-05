#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/shakti_xalen"
mkdir -p ../../android/app/src/main/jniLibs
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 -o ../../android/app/src/main/jniLibs build --release
