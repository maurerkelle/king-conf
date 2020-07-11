#!/usr/local/bin/bash

SOURCE=/home/sk/
TARGET=/net/homes/sk/puck_copy

rsync -avz \
      --exclude '.cache' \
      --exclude '.mu' \
      --exclude '.pw.engineer' \
      --delete $SOURCE $TARGET
