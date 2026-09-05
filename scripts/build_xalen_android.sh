#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${CM_BUILD_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$APP_ROOT"

echo "== Shakti Panchang: build XALEN native Android library =="

if ! command -v cargo >/dev/null 2>&1; then
  if ! command -v rustup >/dev/null 2>&1; then
    echo "Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  source "$HOME/.cargo/env"
fi
source "$HOME/.cargo/env" 2>/dev/null || true

if ! command -v cargo-ndk >/dev/null 2>&1; then
  echo "Installing cargo-ndk..."
  cargo install cargo-ndk --locked
fi

rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android

JNI_DIR="$APP_ROOT/android/app/src/main/jniLibs"
rm -rf "$JNI_DIR"
mkdir -p "$JNI_DIR"

cd "$APP_ROOT/rust/shakti_xalen"

cargo ndk \
  -t arm64-v8a \
  -t armeabi-v7a \
  -t x86_64 \
  -o "$JNI_DIR" \
  build --release

for abi in arm64-v8a armeabi-v7a x86_64; do
  test -s "$JNI_DIR/$abi/libshakti_xalen.so"
done

echo "== XALEN native libraries ready =="
find "$JNI_DIR" -name 'libshakti_xalen.so' -print
