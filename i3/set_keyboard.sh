#!/bin/sh
echo "Running keymapping" >> $HOME/.config/i3/set_keyboard.log
setxkbmap -layout us,de -variant real-prog-qwerty, -option 'grp:alt_space_toggle' 
setxkbmap -option caps:swapescape

