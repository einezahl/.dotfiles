#!/bin/sh
echo "Running keymapping at $(date)" >> $HOME/.config/i3/set_keyboard.log
setxkbmap -layout us,de -variant real-prog-qwerty, -option 'grp:alt_space_toggle' 
setxkbmap -option caps:swapescape
echo "Current layout: $(setxkbmap -query)" >> $HOME/.config/i3/set_keyboard.log
echo "Keymapping completed at $(date)" >> $HOME/.config/i3/set_keyboard.log
