# ffmpeg
FFMPEG 代码 [https://github.com/hilive/XFFmpeg](https://github.com/hilive/XFFmpeg)

output 里是编译好的 ffmpeg 库，可以直接使用

# 编译脚本
## Android
#### 配置 ndk 环境变量 （若报 libgcc_real.a 找不到 可以用 ndk 21.0.6113669 试试）
#### export NDK_PATH=~/Library/Android/sdk/ndk/21.0.6113669


# mediacodec
#### Add hard mediacodec support
#### 添加ffmpeg mediacodec 硬编解码支持

# 使用方式
####  编码
avcodec_find_encoder_by_name("h264_hlmediacodec") 
####  解码
avcodec_find_decoder_by_name("h264_hlmediacodec")

# 更新说明
1、添加 ffmpeg mediacodec 编解码；
2、解决部分机型解码绿边和花屏的问题；
