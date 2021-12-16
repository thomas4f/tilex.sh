#!/bin/bash

# tilex.sh - Bash script that moves windows to preset positions in X.
# Most useful if configured to be launched with keyboard shortcuts.
# Tested with XFCE with default positions for 3440x1440.
#
# Usage: ./tilex.sh name [index]
# Example: ./tilex.sh left 0

# General settings (numeric values in px)
screen_width=3440
screen_height=1440
menu_position=top
menu_size=33
gap_size=5
state_file=/tmp/tilex.tmp

# Window positions (in px or %)
# x, y, width, height
left_top[0]=0%,0%,30%,50%
left[0]=0%,0%,30%,100%
left[1]=0%,0%,50%,100%
left_bottom[0]=0%,50%,30%,50%
top[0]=0%,0%,100%,50%
center[0]=30%,0%,40%,100%
center[1]=0%,0%,100%,100%
bottom[0]=0%,50%,100%,50%
right_top[0]=70%,0%,30%,50%
right[0]=70%,0%,30%,100%
right[1]=50%,0%,50%,100%
right_bottom[0]=70%,50%,30%,50%

check_requirements() {
  if [[ -z $1 ]]; then
    echo "  Usage: $0 name [index]" && exit 1
  fi 
  
  if ! command -v wmctrl &>/dev/null || ! command -v xprop &>/dev/null; then
    echo "  Please install wmctrl and xprop." && exit 1
  fi
  
  declare -ng pos=$1
  
  if [[ -z $pos ]]; then
    echo "  No such position." && exit 1
  fi
}

get_window_position() {
  declare -Ag cur_pos
  
  if [[ -n $2 && -n "${pos[$2]}" ]]; then
    cur_pos[${!pos}]=$2
  elif ! source "${state_file}" &>/dev/null; then
    cur_pos[${!pos}]=0
  fi
}

set_window_geometry() {
  # Unmaximize and get current window id
  window_id=$(wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz -v 2>&1 | \
    grep -oP "Using window: \K.*")

  # Get positions from array
  x=$(cut -d',' -f1 <<< "${pos[${cur_pos[${!pos}]}]}")
  y=$(cut -d',' -f2 <<< "${pos[${cur_pos[${!pos}]}]}")
  width=$(cut -d',' -f3 <<< "${pos[${cur_pos[${!pos}]}]}")
  height=$(cut -d',' -f4 <<< "${pos[${cur_pos[${!pos}]}]}")

  # Get frame extents (eg: titlebar, borders)
  IFS=", " read -r x_left x_right x_top x_bottom \ 
    <<< $(xprop _GTK_FRAME_EXTENTS _NET_FRAME_EXTENTS -id "$window_id" | grep -oP " = \K.*")

  # Convert percent to pixels
  [[ $x == *"%" ]] && x=$(( ${x::-1}*screen_width/100 ))
  [[ $y == *"%" ]] && y=$(( ${y::-1}*screen_height/100 ))
  [[ $width == *"%" ]] && width=$(( ${width::-1}*screen_width/100 ))
  [[ $height == *"%" ]] && height=$(( ${height::-1}*screen_height/100 ))

  # Correct window for menu
  if [[ $menu_position == "top" && $y -eq 0 ]]; then
    y=$(( y+menu_size ))
    height=$(( height-menu_size ))
  elif [[ $menu_position == "right" && ( $width = "$screen_width" || $x -ne 0 ) ]]; then
    width=$(( width-menu_size ))
  elif [[ $menu_position == "bottom" && ( $height = "$screen_height" || $y -ne 0 ) ]]; then
    height=$(( height-menu_size ))
  elif [[ $menu_position == "left" && $x -eq 0 ]]; then
    x=$(( x+menu_size ))
    width=$(( width-menu_size ))
  fi

  # Correct window for decorations and gap
  x=$(( x+gap_size ))
  y=$(( y+gap_size ))
  width=$(( width-x_left-x_right-gap_size*2 ))
  height=$(( height-x_top-x_bottom-gap_size*2 ))
  
  # Move and resize window
  wmctrl -i -r "$window_id" -e 0,$x,$y,$width,$height
}

cycle_window_position() {
  if [[ "${cur_pos[${!pos}]}" -lt $(( ${#pos[@]}-1 )) ]]; then
    (( cur_pos[${!pos}]++ ))
  else
    cur_pos[${!pos}]=0
  fi

  declare -Ap cur_pos | sed 's/ -A/&g/' > ${state_file}
}

check_requirements "$1"
get_window_position "$1" "$2"
set_window_geometry
cycle_window_position

exit 0
