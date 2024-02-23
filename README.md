# 编译脚本
## ffmpeg
FFMPEG 代码 https://github.com/hilive/XFFmpeg

## library
output 里是编译好的 ffmpeg 库，可以直接使用

## examples
demo https://github.com/xffmpeg/examples

# mediacodec
#### Add hard mediacodec support
#### 添加ffmpeg mediacodec 硬编解码支持

# 使用方式
#### encode（编码）
hevc
```c
avcodec_find_encoder_by_name("hevc_hlmediacodec")
```

h264
```c
avcodec_find_encoder_by_name("h264_hlmediacodec")
```

#### decode（解码）
hevc
```c
avcodec_find_decoder_by_name("h264_hlmediacodec")
```

h264
```
avcodec_find_decoder_by_name("h264_hlmediacodec")
```


# 更新说明
1、添加 ffmpeg mediacodec 编解码；
2、解决部分机型解码绿边和花屏的问题；
