#!/bin/bash


xrandr --output DP-2 --mode 1920x1200 --rate 59.95 --output DP-1 --mode 3440x1440 --rate 59.97 --right-of DP-2

xrdb $HOME/.Xresources

# intl us with deadkeys
setxkbmap -layout us -variant intl

# xmodmap $HOME/Config/_Xmodmap

# compton -b

# nitrogen --restore

# synology-drive &

# dropbox start

syncthing -no-browser &

fvwm



