#!/bin/bash

source ./build_android_common.sh

BASE_DIR=$(cd `dirname $0`; pwd)
SOURCE=$BASE_DIR/../XFFmpeg
THIRD_DIR=$BASE_DIR/3rd
BINARY_DIR=$BASE_DIR/binary/android
OUTPUT_DIR=$BASE_DIR/output/android
OUTPUT_NAME=libxffmpeg.so


function build_ffmpeg {
  ARCH=$1
  ABI=$2
  ABI_TRIPLE=$3

  echo "build_ffmpeg start ########################### ARCH: $ARCH ABI: $ABI ABI_TRIPLE: $ABI_TRIPLE"

  PREFIX_DIR=$BINARY_DIR/ffmpeg/$ABI

  rm -rf $PREFIX_DIR

  SSL_INC=$THIRD_DIR/openssl/Android/$ABI/include
  SSL_LIB=$THIRD_DIR/openssl/Android/$ABI/lib

  set_android_toolchain "ffmpeg" "${ARCH}" "${API_LEVEL}"
  set_android_cpu_feature "ffmpeg" "${ARCH}" "${API_LEVEL}"

  local includes=$(get_common_includes)
  local toolchain=$(get_toolchain)
  local build_host=$(android_get_build_host "$ARCH")

  TOOLCHAIN=$NDK_ROOT/toolchains/llvm/prebuilt/$toolchain
  SYSROOT=$TOOLCHAIN/sysroot
  CROSS_COMPILE=$TOOLCHAIN/bin/$build_host-
#  SYSROOT=$TOOLCHAIN/sysroot/usr/include/$build_host
#  SYSROOT=$NDK_ROOT/platforms/android-$API_LEVEL/arch-$ARCH

  echo "CFLAGS: ${CFLAGS}"
  echo "LDFLAGS: ${LDFLAGS}"
  echo "CXXFLAGS: ${CXXFLAGS}"
  echo "toolchain: ${toolchain}"
  echo "build_host: ${build_host}"
  echo "NM: ${NM}"
  echo "CC: ${CC}"
  echo "CXX: ${CXX}"

  cd $SOURCE

  ./configure \
    --prefix=$PREFIX_DIR \
    --arch=$ARCH \
    --target-os=android \
    --cc=$CC \
    --cxx=$CXX \
    --cross-prefix=$build_host- \
    --nm=$NM \
    --as=$AS \
    --sysroot=$SYSROOT \
    --enable-cross-compile \
    --disable-everything \
    --enable-gpl \
    --enable-nonfree \
    --enable-runtime-cpudetect \
    --disable-doc \
    --disable-programs \
    --enable-debug \
    --disable-symver \
    --enable-static \
    --enable-pthreads \
    --enable-pic \
    --disable-stripping \
    --disable-devices \
    --enable-small \
    --disable-asm \
    --enable-neon \
    --extra-cflags="$CPPFLAGS -DHILIVE_SYS_ANDROID -DHILIVE_DEBUG -DANDROID" \
    --disable-encoders \
    --enable-encoder=aac \
    --enable-encoder=mjpeg \
    --enable-encoder=mpeg4 \
    --enable-encoder=bmp \
    --enable-encoder=aac_at \
    --enable-encoder=gif \
    --disable-decoders \
    --enable-decoder=pcm_alaw \
    --enable-decoder=pcm_f32be \
    --enable-decoder=pcm_f32le \
    --enable-decoder=pcm_f64be \
    --enable-decoder=pcm_f64le \
    --enable-decoder=pcm_lxf \
    --enable-decoder=pcm_mulaw \
    --enable-decoder=pcm_s16be \
    --enable-decoder=pcm_s16be_planar \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s16le_planar \
    --enable-decoder=pcm_s24be \
    --enable-decoder=pcm_s24daud \
    --enable-decoder=pcm_s24le \
    --enable-decoder=pcm_s24le_planar \
    --enable-decoder=pcm_s32be \
    --enable-decoder=pcm_s32le \
    --enable-decoder=pcm_s32le_planar \
    --enable-decoder=pcm_s8 \
    --enable-decoder=pcm_s8_planar \
    --enable-decoder=pcm_u16be \
    --enable-decoder=pcm_u16le \
    --enable-decoder=pcm_u24be \
    --enable-decoder=pcm_u24le \
    --enable-decoder=pcm_u32be \
    --enable-decoder=pcm_u32le \
    --enable-decoder=pcm_u8 \
    --enable-decoder=wavpack \
    --enable-decoder=wmapro \
    --enable-decoder=wmav1 \
    --enable-decoder=wmav2 \
    --enable-decoder=wmalossless \
    --enable-decoder=wmavoice \
    --enable-decoder=adpcm_ima_amv \
    --enable-decoder=adpcm_ima_wav \
    --enable-decoder=adpcm_ima_ws \
    --enable-decoder=adpcm_ima_apc \
    --enable-decoder=adpcm_ms \
    --enable-decoder=adpcm_4xm \
    --enable-decoder=adpcm_adx \
    --enable-decoder=adpcm_afc \
    --enable-decoder=adpcm_aica \
    --enable-decoder=adpcm_ct \
    --enable-decoder=adpcm_dtk \
    --enable-decoder=adpcm_ea \
    --enable-decoder=adpcm_ea_maxis_xa \
    --enable-decoder=adpcm_ea_r1 \
    --enable-decoder=adpcm_ea_xas \
    --enable-decoder=adpcm_g722 \
    --enable-decoder=adpcm_g726 \
    --enable-decoder=adpcm_g726le \
    --enable-decoder=adpcm_psx \
    --enable-decoder=adpcm_sbpro_2 \
    --enable-decoder=adpcm_swf \
    --enable-decoder=adpcm_thp \
    --enable-decoder=adpcm_thp_le \
    --enable-decoder=adpcm_vima \
    --enable-decoder=adpcm_xa \
    --enable-decoder=vorbis \
    --enable-decoder=mjpeg \
    --enable-decoder=mpegvideo \
    --enable-decoder=mpeg1video \
    --enable-decoder=mpeg2video \
    --enable-decoder=mpeg4 \
    --enable-decoder=vp8 \
    --enable-decoder=vp9 \
    --enable-decoder=wmv1 \
    --enable-decoder=wmv2 \
    --enable-decoder=wmv3 \
    --enable-decoder=aac \
    --enable-decoder=opus \
    --enable-hlmediacodec \
    --enable-encoder=h264_hlmediacodec \
    --enable-decoder=h264_hlmediacodec \
    --enable-decoder=hevc_hlmediacodec \
    --enable-decoder=mpeg4_hlmediacodec \
    --enable-decoder=hevc \
    --enable-decoder=h264 \
    --enable-decoder=mp3 \
    --enable-decoder=ape \
    --enable-decoder=gif \
    --enable-decoder=srt \
    --enable-decoder=ssa \
    --enable-decoder=ass \
    --enable-decoder=subrip \
    --enable-decoder=flac \
    --enable-decoder=alac \
    --enable-decoder=webvtt \
    --disable-muxers \
    --enable-muxer=image2 \
    --enable-muxer=mp4 \
    --enable-muxer=adts \
    --enable-muxer=mjpeg \
    --enable-muxer=h264 \
    --enable-muxer=hevc \
    --enable-muxer=mpegts \
    --enable-muxer=ac3 \
    --disable-demuxers \
    --enable-demuxer=rtsp \
    --enable-demuxer=hls \
    --enable-demuxer=mp3 \
    --enable-demuxer=aac \
    --enable-demuxer=h264 \
    --enable-demuxer=hevc \
    --enable-demuxer=mpegtsraw \
    --enable-demuxer=mpegvideo \
    --enable-demuxer=mpegps \
    --enable-demuxer=mpegts \
    --enable-demuxer=m4v \
    --enable-demuxer=mov \
    --enable-demuxer=asf \
    --enable-demuxer=ogg \
    --enable-demuxer=flac \
    --enable-demuxer=ape \
    --enable-demuxer=wav \
    --enable-demuxer=amr \
    --enable-demuxer=flv \
    --enable-demuxer=gif \
    --enable-demuxer=mjpeg \
    --enable-demuxer=image2 \
    --enable-demuxer=pcm_alaw \
    --enable-demuxer=pcm_f32be \
    --enable-demuxer=pcm_f32le \
    --enable-demuxer=pcm_f64be \
    --enable-demuxer=pcm_f64le \
    --enable-demuxer=pcm_mulaw \
    --enable-demuxer=pcm_s16be \
    --enable-demuxer=pcm_s16le \
    --enable-demuxer=pcm_s24be \
    --enable-demuxer=pcm_s24le \
    --enable-demuxer=pcm_s32be \
    --enable-demuxer=pcm_s32le \
    --enable-demuxer=pcm_s8 \
    --enable-demuxer=pcm_u16be \
    --enable-demuxer=pcm_u16le \
    --enable-demuxer=pcm_u24be \
    --enable-demuxer=pcm_u24le \
    --enable-demuxer=pcm_u32be \
    --enable-demuxer=pcm_u32le \
    --enable-demuxer=pcm_u8 \
    --enable-demuxer=srt \
    --enable-demuxer=ac3 \
    --enable-demuxer=eac3 \
    --disable-parsers \
    --enable-parser=mjpeg \
    --enable-parser=aac \
    --enable-parser=hevc \
    --enable-parser=h264 \
    --enable-parser=mpegaudio \
    --enable-parser=mpeg4video \
    --enable-parser=mpegvideo \
    --enable-parser=ac3 \
    --disable-protocols \
    --enable-protocol=hls \
    --enable-protocol=http \
    --enable-protocol=httpproxy \
    --enable-protocol=https \
    --enable-protocol=rtmp \
    --enable-protocol=file \
    --enable-protocol=crypto \
    --disable-bsfs \
    --enable-bsf=aac_adtstoasc \
    --enable-bsf=h264_mp4toannexb \
    --enable-bsf=hevc_mp4toannexb \
    --enable-bsf=h264_metadata \
    --enable-filters \
    --enable-openssl \
    --extra-cflags="-I$SSL_INC" \
    --extra-ldflags="-L$SSL_LIB -lz -lm" \
    --disable-avdevice \
    --disable-postproc \
    --disable-avresample

  make -j$(get_cpu_count)
  make install
  make clean

  cd $BASE_DIR

  echo "build_ffmpeg end ###########################"
}

function check_lib {
  ARCH=$1
  ABI=$2
  ABI_TRIPLE=$3

  echo "check_lib start ########################### ARCH: $ARCH ABI: $ABI ABI_TRIPLE: $ABI_TRIPLE"

#   FDKAAC_DIR=$BINARY_DIR/fdk-aac/$ABI
  FFMPEG_DIR=$BINARY_DIR/ffmpeg/$ABI

#   DIRS=("$FDKAAC_DIR" "$FFMPEG_DIR")
  DIRS=("$FFMPEG_DIR")

  for i in "${!DIRS[@]}";
  do
    if [ ! -d "${DIRS[$i]}" ]; then
      echo "${DIRS[$i]} unready!!!!!!!"
    else
      echo "${DIRS[$i]} ready"
    fi

  done

  echo "check_lib end ###########################"
}

function merge_lib {
  ARCH=$1
  ABI=$2
  ABI_TRIPLE=$3

  echo "merge_lib start ########################### ARCH: $ARCH API: $API ABI_TRIPLE: $ABI_TRIPLE"

  SSL_INC=$THIRD_DIR/openssl/Android/$ABI/include
  SSL_LIB=$THIRD_DIR/openssl/Android/$ABI/lib
  FFMPEG_INC=$BINARY_DIR/ffmpeg/$ABI/include
  FFMPEG_LIB=$BINARY_DIR/ffmpeg/$ABI/lib
  INC_OUT_DIR=$OUTPUT_DIR/$ABI/include
  LIBS_OUT_DIR=$OUTPUT_DIR/$ABI/libs

  set_android_toolchain "merge" "${ARCH}" "${API_LEVEL}"
  set_android_cpu_feature "merge" "${ARCH}" "${API_LEVEL}"

  local toolchain=$(get_toolchain)
  local build_host=$(android_get_build_host "$ARCH")
  local sys_libs=$(get_common_linked_libraries)

  TOOLCHAIN=$NDK_ROOT/toolchains/llvm/prebuilt/$toolchain
  SYSROOT=$TOOLCHAIN/sysroot
  SYS_LIBS=$SYSROOT/usr/lib/$build_host/$API_LEVEL
  GCCLIB=$TOOLCHAIN/lib/gcc/$build_host/4.9.x/libgcc_real.a

  echo "arch="$ARCH
  echo "toolchain="$toolchain
  echo "build_host="$build_host
  echo "CROSS_COMPILE="$CROSS_COMPILE
  echo "SSL_INC="$SSL_INC
  echo "FFMPEG_INC="$FFMPEG_INC
  echo "LIBS_OUT_DIR="$LIBS_OUT_DIR
  echo "INC_OUT_DIR="$INC_OUT_DIR
  echo "LD="$LD
  echo "merge lib ..."

  rm -rf $INC_OUT_DIR
  rm -rf $LIBS_OUT_DIR

  mkdir -p $INC_OUT_DIR
  mkdir -p $LIBS_OUT_DIR

  cp -r $SSL_INC/* $INC_OUT_DIR
  cp -r $FFMPEG_INC/* $INC_OUT_DIR

  $LD -rpath-link=$SYS_LIBS -L$SYS_LIBS \
      -soname $OUTPUT_NAME -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o $LIBS_OUT_DIR/$OUTPUT_NAME \
      $SSL_LIB/libssl.a \
      $SSL_LIB/libcrypto.a \
      $FFMPEG_LIB/libavcodec.a \
      $FFMPEG_LIB/libswresample.a \
      $FFMPEG_LIB/libswscale.a \
      $FFMPEG_LIB/libavformat.a \
      $FFMPEG_LIB/libavfilter.a \
      $FFMPEG_LIB/libavutil.a \
      -lc -lm -lz -ldl -llog -lmediandk --dynamic-linker=/system/bin/linker $GCCLIB

  echo "merge_lib end ###########################"

  SO_FILE=$LIBS_OUT_DIR/$OUTPUT_NAME
  echo "SO_FILE: "$SO_FILE
}

set_android_toolchain_bin


ARCHS=("arm" "arm64")
ABIS=("armeabi-v7a" "arm64-v8a")

for i in "${!ARCHS[@]}";
do
  ARCH=${ARCHS[$i]}
  ABI=${ABIS[$i]}
  ABI_TRIPLE=${ARCHS[$i]}-linux-android
  echo "ARCH: $ARCH, ABI: $ABI, ABI_TRIPLE: $ABI_TRIPLE"

  build_ffmpeg "$ARCH" "$ABI" "$ABI_TRIPLE"
  check_lib "$ARCH" "$ABI" "$ABI_TRIPLE"
  merge_lib "$ARCH" "$ABI" "$ABI_TRIPLE"
done
