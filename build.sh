#!/bin/sh
export APP_NAME=arkanoid-1.0.swf
export PATH=$PATH:/opt/flashplayer
export LOG_FILE=/home/codein/.macromedia/Flash_Player/Logs/flashlog.txt
mvn -DskipTests=true clean install
tail -f -n 100 $LOG_FILE &
flashplayer target/$APP_NAME

