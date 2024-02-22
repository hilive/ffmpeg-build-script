#!/bin/sh
BASE_DIR=$(cd `dirname $0`; pwd)
SOURCE=$BASE_DIR/../XFFmpeg
OUTPUT_DIR=$BASE_DIR/output/mac
BINARY_DIR=$BASE_DIR/binary/mac/ffmpeg

DEPLOYMENT_TARGET="14.0"

ARCHS="arm64 x86_64"


CONFIGURE_FLAGS="--enable-cross-compile \
--disable-debug \
--disable-programs \
--disable-everything \
--disable-doc \
--disable-htmlpages \
--disable-manpages \
--disable-podpages \
--disable-txtpages \
--disable-shared \
--disable-indevs \
--disable-outdevs \
--disable-devices \
--disable-postproc \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-symver \
--disable-stripping \
--disable-muxers \
--disable-gpl \
--disable-version3 \
--disable-nonfree \
--enable-small \
--enable-static \
--enable-asm \
--enable-neon \
--enable-swresample \
--enable-swscale \
--enable-avdevice \
--enable-avfilter \
--enable-filters \
--enable-pthreads \
--enable-openssl \
--enable-network \
--enable-protocol=http \
--enable-protocol=https \
--enable-protocol=rtsp \
--enable-protocol=rtmp \
--enable-runtime-cpudetect \
--enable-protocol=file \
--enable-decoder=aac \
--enable-decoder=mp3 \
--enable-decoder=mjpeg \
--enable-decoder=h264 \
--enable-decoder=hevc \
--enable-decoder=mpeg4 \
--enable-videotoolbox \
--enable-audiotoolbox \
--enable-demuxer=flv \
--enable-demuxer=h264 \
--enable-demuxer=hevc \
--enable-demuxer=mp3 \
--enable-demuxer=aac \
--enable-demuxer=mpegvideo \
--enable-demuxer=m4v \
--enable-demuxer=mov \
--enable-demuxer=mjpeg \
--enable-demuxer=image2 \
--enable-muxer=image2 \
--enable-muxer=mp4 \
--enable-muxer=adts \
--enable-muxer=mjpeg \
--enable-muxer=h264 \
--enable-muxer=hevc \
--enable-encoder=mjpeg \
--enable-encoder=mpeg4 \
--enable-encoder=bmp \
--enable-encoder=aac \
--enable-encoder=aac_at \
--enable-encoder=h264_videotoolbox \
--enable-encoder=hevc_videotoolbox \
--enable-parser=aac \
--enable-parser=mpeg4video \
--enable-parser=mjpeg \
--enable-parser=h264 \
--enable-parser=hevc \
--enable-parser=mpeg4video \
--enable-hwaccels \
--enable-filter=colormatrix,rotate,color,format,scale,null,trim \
--enable-filter=crop,scale2ref,swapuv,allyuv,allrgb,aresample,metadata \
--enable-bsf=aac_adtstoasc \
--enable-bsf=h264_mp4toannexb \
--enable-bsf=hevc_mp4toannexb \
--enable-bsf=h264_metadata \
--enable-protocol=file \
--extra-cflags=-g \
--extra-cflags=-gline-tables-only \
"

if [ ! `which yasm` ]
then
	echo 'Yasm not found'
	if [ ! `which brew` ]
	then
		echo 'Homebrew not found. Trying to install...'
											ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
			|| exit 1
	fi
	echo 'Trying to install Yasm...'
	brew install yasm || exit 1
fi
if [ ! `which gas-preprocessor.pl` ]
then
	echo 'gas-preprocessor.pl not found. Trying to install...'
	(curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
		-o /usr/local/bin/gas-preprocessor.pl \
		&& chmod +x /usr/local/bin/gas-preprocessor.pl) \
		|| exit 1
fi


function build
{
for ARCH in $ARCHS
do
	echo "building $ARCH..."

	cd $SOURCE

	CFLAGS="-arch $ARCH"
    PLATFORM="MacOSX"
    CFLAGS="$CFLAGS -mmacosx-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
    if [ "$ARCH" = "arm64e" -o "$ARCH" = "arm64" ]
    then
            EXPORT="GASPP_FIX_XCODE5=1"
    fi

	XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
	CC="xcrun -sdk $XCRUN_SDK clang"

	# force "configure" to use "gas-preprocessor.pl" (FFmpeg 3.3)
	if [ "$ARCH" = "arm64e" -o "$ARCH" = "arm64" ]
	then
			AS="gas-preprocessor.pl -arch aarch64 -- $CC"
	else
			AS="gas-preprocessor.pl -- $CC"
	fi

	CXXFLAGS="$CFLAGS"
	LDFLAGS="$CFLAGS"
	SSL_DIR=$BASE_DIR/3rd/openssl/Mac
	SSL_INC=$SSL_DIR/include
	SSL_LIB=$SSL_DIR/lib
	ARCH_DIR=$BINARY_DIR/$ARCH

	./configure \
			--target-os=darwin \
			--arch=$ARCH \
			--cc="$CC" \
			--as="$AS" \
			--extra-cflags="$CFLAGS -DHILIVE_XFFMPEG -I$SSL_INC" \
			--extra-ldflags="$LDFLAGS -L$SSL_LIB" \
			--prefix=$ARCH_DIR \
			$CONFIGURE_FLAGS

	make clean
	make -j 16
	make install
	cd $BASE_DIR
done
}

function merge
{
echo "merge libs..."

mkdir -p $OUTPUT_DIR/include
mkdir -p $OUTPUT_DIR/lib

set - $ARCHS
cd $BINARY_DIR/$1/lib
for LIB in *.a
do
	echo lipo -create `find $BINARY_DIR -name $LIB` -output $OUTPUT_DIR/lib/$LIB 1>&2
	lipo -create `find $BINARY_DIR -name $LIB` -output $OUTPUT_DIR/lib/$LIB || exit 1
done

cp -rf $BINARY_DIR/$1/include $OUTPUT_DIR
}

build
merge

echo Done