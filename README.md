# ffmpeg
已经重新基于 [https://github.com/hilive/XFFmpeg](https://github.com/hilive/XFFmpeg)

# 编译脚本
## Android
#### 配置 ndk 环境变量 （若报 libgcc_real.a 找不到 可以用 ndk 21.0.6113669 试试）
#### export NDK_PATH=~/Library/Android/sdk/ndk/21.0.6113669


# mediacodec
#### Add hard mediacodec support
#### 添加ffmpeg mediacodec 硬编解码支持

# 说明
#### 使用方式 avcodec_find_encoder_by_name("h264_hlmediacodec") avcodec_find_decoder_by_name("h264_hlmediacodec")
