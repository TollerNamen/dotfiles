#!/usr/bin/env bash

state_file="$HOME/.config/sway/scripts/current_brightness"
declare -i kbd_light=$(cat $state_file)

case $1 in
    n) (( kbd_light < 3 )) && (( kbd_light++ ));;
    p) (( kbd_light > 0 )) && (( kbd_light-- ));;
    *) echo "Usage: $0 [n|p]" >&2; exit 1;;
esac

echo $kbd_light > $state_file
echo $kbd_light
cat $state_file

case $kbd_light in
    0) mode="off";;
    1) mode="low";;
    2) mode="med";;
    3) mode="high";;
    *) echo "Invalid brightness level: $kbd_light" >&2; exit 1;;
esac

echo $mode
exec asusctl -k "$mode"