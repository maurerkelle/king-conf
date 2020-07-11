#!/usr/local/bin/bash

SOURCE=/home/sk/
TARGET=/net/homes/sk/puck_copy

rsync -avz --delete $SOURCE $TARGET
