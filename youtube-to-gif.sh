# Extract a portion of a youtube video, make it a gif and upload it to giphy#
#
# TODO param list, help, etc

# parameters with default values
# https://stackoverflow.com/questions/9332802/how-to-write-a-bash-script-that-takes-optional-input-arguments

VIDEO_FULL_URL="$1"
START_TIME=${2:-00:00:00}
END_TIME=${3:-00:00:10}
if [ -z "$4" ]; then
    NAME=`/bin/echo $VIDEO_FULL_URL | /usr/bin/md5sum | /usr/bin/cut -f1 -d" "`
else
    NAME=$4
fi
DEST_GIF="./exported_gifs/${NAME}.gif"
FRAME_RATE=15
FILTER_OPTIONS="scale=512:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"
YT_DL_FORMAT=${5:-bestvideo}

SRC_FILE=".yt_videos/${YT_DL_FORMAT}_${NAME}"
if [ ! -f "$SRC_FILE" ]; then
    youtube-dl $VIDEO_FULL_URL -o $SRC_FILE #-f $YT_DL_FORMAT
    if [ $? -eq 0 ]; then
        SRC_FILE=`ls $SRC_FILE*`
    else
        echo ""
        echo "Error while downloading video from youtube"
        echo ""
        exit 1
    fi
else
    echo "video \"${SRC_FILE}\" found in cache, skipping download (delete it if you want to download it again)"
fi

echo ""
echo "Starting convertion, please wait, it may take a while..."
ffmpeg -y -i $SRC_FILE \
    -r $FRAME_RATE \
    -vf $FILTER_OPTIONS \
    -ss $START_TIME \
    -to $END_TIME \
    -loglevel quiet \
    $DEST_GIF
    
if [ $? -eq 0 ]; then
    DEST_GIF_SIZE=`stat --printf="%s" $DEST_GIF`
    DEST_GIF=`realpath $DEST_GIF`
else
    echo ""
    echo "Error while creating gif"
    echo ""
    exit 2
fi

API_KEY="$API_KEY" 
USERNAME="$API_USERNAME" 
TAGS=""
SOURCE="source"

printf -v API_ENDPOINT 'https://upload.giphy.com/v1/gifs?api_key=%s&username=%s&tags=%s&source_post_url=%s' "$API_KEY" "$USERNAME" "$TAGS" "$SOURCE"
printf -v HEADER 'Content-Type: multipart/form-data; boundary=--------------------------2894808846193452954786963417' # boundary is a random string used to delimit end of file # oui, c'est immonde....
printf -v DEST_GIF_FORM 'file=@%s' "$DEST_GIF"

echo ""
echo "uploading gif to $API_ENDPOINT, please wait..."
GIF_ID=`curl --location --request POST "$API_ENDPOINT" --header "$HEADER" --form "$DEST_GIF_FORM" | jq -r '.data.id'`
echo ""
echo "Gif succesfully created at $DEST_GIF ($DEST_GIF_SIZE bytes)"
echo "Gif uploaded to https://giphy.com/gifs/$GIF_ID"
echo ""
