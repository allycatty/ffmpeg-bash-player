#!/bin/bash

TIME=`cat ".time"`
INU=`cat ".inu"`
MAP1=`cat ".map1"`
MAP2=`cat ".map2"`
REZ=`cat ".rez"`

# // THIS IS THE DEFAULT CONFIG FILE FOR FFMPEG //
# // SET FOR NVIDIA HARDWARE TRANSCODING //
# // AND STREAMING TO LOCAL RTMP SERVER. //
# // PLACE IN HOME OR PLAYING DIR and EDIT ACCORDINGLY <3 //

ffmpeg \
-vsync 0 -hwaccel_output_format cuda \
-c:v h264_cuvid -resize $REZ -re -ss $TIME -i "$INU" \
-vf "setpts=PTS+$TIME/TB",\
"subtitles='$INU'",\
"setpts=PTS-STARTPTS,hwupload_cuda" \
-c:v h264_nvenc -preset:v llhq \
-gpu:v any -level:v 6.2 -rc:v cbr_hq \
-spatial_aq:v 1 -aq-strength:v 10 -coder:v cabac \
-maxrate 4000k -bufsize 5000k \
-g 50 -c:a aac -b:a 160k -ac 2 -ar 44100 \
-force_key_frames "expr:gte(t,n_forced*3)" \
-err_detect ignore_err -ignore_unknown \
-map 0:$MAP1 -map 0:$MAP2 \
-f flv rtmp://127.0.0.1/show/stream > /tmp/fftime.txt 2>&1
exit

