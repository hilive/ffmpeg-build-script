#!/bin/bash

ARCHS=("arm" "arm64" "x86" "x86_64")
ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
API_LEVEL=23
CPP_LEVEL=11

export NDK_PATH=~/Library/Android/sdk/ndk/21.0.6113669

if [[ -z ${NDK_PATH} ]]; then
  echo "NDK_PATH not defined"
  exit -101
fi

function get_cpu_count() {
    if [ "$(uname)" == "Darwin" ]; then
        echo $(sysctl -n hw.physicalcpu)
    else
        echo $(nproc)
    fi
}

function get_toolchain() {
  HOST_OS=$(uname -s)
  case ${HOST_OS} in
  Darwin) HOST_OS=darwin ;;
  Linux) HOST_OS=linux ;;
  FreeBsd) HOST_OS=freebsd ;;
  CYGWIN* | *_NT-*) HOST_OS=cygwin ;;
  esac

  HOST_ARCH=$(uname -m)
  case ${HOST_ARCH} in
  i?86) HOST_ARCH=x86 ;;
  x86_64 | amd64 | arm64) HOST_ARCH=x86_64 ;;
  esac

  echo "${HOST_OS}-${HOST_ARCH}"
}

function get_android_arch() {
  local common_arch=$1
  case ${common_arch} in
  arm)
    echo "arm-v7a"
    ;;
  arm64)
    echo "arm64-v8a"
    ;;
  x86)
    echo "x86"
    ;;
  x86_64)
    echo "x86-64"
    ;;
  esac
}

function get_target_build() {
  local arch=$1
  case ${arch} in
  arm-v7a)
    echo "arm"
    ;;
  arm64-v8a)
    echo "arm64"
    ;;
  x86)
    echo "x86"
    ;;
  x86-64)
    echo "x86_64"
    ;;
  esac
}


function get_build_host_prefix() {
  local arch=$1
  case ${arch} in
  arm-v7a | arm-v7a-neon)
    echo "arm-linux"
    ;;
  arm64-v8a)
    echo "aarch64-linux"
    ;;
  x86)
    echo "i686-linux"
    ;;
  x86-64)
    echo "x86_64-linux"
    ;;
  esac
}

function android_get_host_prefix() {
  local arch=$(get_android_arch $1)
  get_build_host_prefix $arch
}

function get_build_host_internal() {
  local arch=$1
  case ${arch} in
  arm-v7a | arm-v7a-neon)
    echo "arm-linux-androideabi"
    ;;
  arm64-v8a)
    echo "aarch64-linux-android"
    ;;
  x86)
    echo "i686-linux-android"
    ;;
  x86-64)
    echo "x86_64-linux-android"
    ;;
  esac
}

function android_get_build_host() {
  local arch=$(get_android_arch $1)
  get_build_host_internal $arch
}

function get_clang_target_host() {
  local arch=$1
  local api=$2
  case ${arch} in
  arm-v7a | arm-v7a-neon)
    echo "armv7a-linux-androideabi${api}"
    ;;
  arm64-v8a)
    echo "aarch64-linux-android${api}"
    ;;
  x86)
    echo "i686-linux-android${api}"
    ;;
  x86-64)
    echo "x86_64-linux-android${api}"
    ;;
  esac
}

function set_android_toolchain_bin() {
  export PATH=${NDK_PATH}/toolchains/llvm/prebuilt/$(get_toolchain)/bin:$PATH
  echo PATH=$PATH
}

function set_android_toolchain() {
  local name=$1
  local arch=$(get_android_arch $2)
  local api=$3
  local build_host=$(get_build_host_internal "$arch")
  local clang_target_host=$(get_clang_target_host "$arch" "$api")

  export AR=${build_host}-ar
  export CC=${clang_target_host}-clang
  export CXX=${clang_target_host}-clang++
  export NM=${build_host}-nm
  export AS=${build_host}-as
  export LD=${build_host}-ld
  export RANLIB=${build_host}-ranlib
  export STRIP=${build_host}-strip
}

function get_common_includes() {
  local toolchain=$(get_toolchain)
  echo "-I${NDK_PATH}/toolchains/llvm/prebuilt/${toolchain}/sysroot/usr/include -I${NDK_PATH}/toolchains/llvm/prebuilt/${toolchain}/sysroot/usr/local/include"
}

function get_common_linked_libraries() {
  local api=$1
  local arch=$2
  local toolchain=$(get_toolchain)
  local build_host=$(get_build_host_internal "$arch")
  echo "-L${NDK_PATH}/toolchains/llvm/prebuilt/${toolchain}/${build_host}/lib -L${NDK_PATH}/toolchains/llvm/prebuilt/${toolchain}/sysroot/usr/lib/${build_host}/${api} -L${NDK_PATH}/toolchains/llvm/prebuilt/${toolchain}/lib"
}

function set_android_cpu_feature() {
  local name=$1
  local arch=$(get_android_arch $2)
  local api=$3
  case ${arch} in
  arm-v7a | arm-v7a-neon)
    export CFLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wno-unused-function -fno-integrated-as -fstrict-aliasing -fPIC -DANDROID -D__ANDROID_API__=${api} -Os -ffunction-sections -fdata-sections -fno-omit-frame-pointer $(get_common_includes)"
    export CXXFLAGS="-std=c++${CPP_LEVEL} -Os -ffunction-sections -fdata-sections -fno-omit-frame-pointer"
    export LDFLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wl,--fix-cortex-a8 -Wl,--gc-sections -Os -ffunction-sections -fdata-sections $(get_common_linked_libraries ${api} ${arch})"
    export CPPFLAGS=${CFLAGS}
    ;;
  arm64-v8a)
    export CFLAGS="-march=armv8-a -Wno-unused-function -fno-integrated-as -fstrict-aliasing -fPIC -DANDROID -D__ANDROID_API__=${api} -Os -ffunction-sections -fdata-sections -fno-omit-frame-pointer $(get_common_includes)"
    export CXXFLAGS="-std=c++${CPP_LEVEL} -Os -ffunction-sections -fdata-sections -fno-omit-frame-pointer"
    export LDFLAGS="-march=armv8-a -Wl,--gc-sections -Os -ffunction-sections -fdata-sections $(get_common_linked_libraries ${api} ${arch})"
    export CPPFLAGS=${CFLAGS}
    ;;
  x86)
    export CFLAGS="-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32 -Wno-unused-function -fno-integrated-as -fstrict-aliasing -fPIC -DANDROID -D__ANDROID_API__=${api} -Os -ffunction-sections -fdata-sections -fno-omit-frame-pointer $(get_common_includes)"
    export CXXFLAGS="-std=c++${CPP_LEVEL} -Os -ffunction-sections -fdata-sections -fno-omit-frame-pointer"
    export LDFLAGS="-march=i686 -Wl,--gc-sections -Os -ffunction-sections -fdata-sections $(get_common_linked_libraries ${api} ${arch})"
    export CPPFLAGS=${CFLAGS}
    ;;
  x86-64)
    export CFLAGS="-march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -Wno-unused-function -fno-integrated-as -fstrict-aliasing -fPIC -DANDROID -D__ANDROID_API__=${api} -Os -ffunction-sections -fdata-sections -fno-omit-frame-pointer $(get_common_includes)"
    export CXXFLAGS="-std=c++${CPP_LEVEL} -Os -ffunction-sections -fdata-sections -fno-omit-frame-pointer"
    export LDFLAGS="-march=x86-64 -Wl,--gc-sections -Os -ffunction-sections -fdata-sections $(get_common_linked_libraries ${api} ${arch})"
    export CPPFLAGS=${CFLAGS}
    ;;
  esac
}

function android_printf_global_params() {
  echo -e "arch =           $arch"
  echo -e "abi =            $abi"
  echo -e "abi_triple =     $abi_triple"
  echo -e "PLATFORM_TYPE =  $PLATFORM_TYPE"
  echo -e "ANDROID_API =    $ANDROID_API"
  echo -e "in_dir =         $in_dir"
  echo -e "out_dir =        $out_dir"
  echo -e "AR =             $AR"
  echo -e "CC =             $CC"
  echo -e "CXX =            $CXX"
  echo -e "AS =             $AS"
  echo -e "LD =             $LD"
  echo -e "RANLIB =         $RANLIB"
  echo -e "STRIP =          $STRIP"
  echo -e "CFLAGS =         $CFLAGS"
  echo -e "CXXFLAGS =       $CXXFLAGS"
  echo -e "LDFLAGS =        $LDFLAGS"
  echo -e "CPPFLAGS =       $CPPFLAGS"
}

