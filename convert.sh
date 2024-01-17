#!/bin/bash

cleanup() {
    rm -f .tmpConvert*
    exit 1
}

trap 'cleanup' ERR

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
APP_DIR="$SCRIPT_DIR/build/app"

if [ ! -f "$APP_DIR/ConvApp" ]; then
    echo -e "ERROR: expected to find ConvApp in $APP_DIR" >>/dev/stderr
    exit 1
fi

INPUT=$1
OUTPUT=$2
NB_FRAMES=2000
if [ ! -z "$3" ]; then
    NB_FRAMES=$3
fi

# FUTURE PARAMS
WIDTH=1920
HEIGHT=1080
SOURCE_FMT="yuv420p"

RESOLUTION="${WIDTH}x${HEIGHT}"

echo "EXTRACT $NB_FRAMES FRAMES AS RAW DATA"
ffmpeg -y -i $INPUT -vframes $NB_FRAMES -c:v: rawvideo .tmpConvert1.yuv > /dev/null
echo "CONVERT TO YUV422 10LE"
ffmpeg -y -s $RESOLUTION -pix_fmt $SOURCE_FMT -i .tmpConvert1.yuv -pix_fmt yuv422p10le .tmpConvert2.yuv > /dev/null
echo "CONVERT TO RFC 4175"
$APP_DIR/ConvApp -width $WIDTH -height $HEIGHT -in_pix_fmt yuv422p10le -i .tmpConvert2.yuv -out_pix_fmt yuv422rfc4175be10 -o $OUTPUT

# clean up
rm -f .tmpConvert*
