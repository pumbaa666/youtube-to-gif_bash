# Setup
Install youtube-dl `sudo apt install youtube-dl`

# Launch
Replace the variable values and execute this code :

```
VIDEO_FULL_URL="https://www.youtube.com/watch?v=vm3X1jx9q44"
NAME="vm3X1jx9q44"
START_TIME=00:00:22
END_TIME=00:00:25

export API_KEY="YOUR GIPHY API KEY"
export API_USERNAME="YOUR GIPHY USERNAME"
./youtube-to-gif.sh $VIDEO_FULL_URL $NAME $START_TIME $END_TIME

```

You can see all the video providers allowed by running `youtube-dl --list-extractors`
