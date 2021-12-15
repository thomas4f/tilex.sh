#!/bin/bash

# tilex.sh - Bash script that moves windows to preset positions in X.
# Most useful if configured to be launched with keyboard shortcuts.
# 
# Tested with XFCE with default positions for 3440x1440.
# Example: ./tilex.sh left

# General settings
screen_width=3440
screen_height=1440
menu_position=top
menu_height=33
gap_size=3
state_file=/tmp/tilex.tmp

# Window positions (x, y, width, height)
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
    echo -e "  Usage: $0 \e[3mposition\e[0m" && exit 1
  fi 
  
  if ! command -v wmctrl &>/dev/null || ! command -v xwininfo &>/dev/null; then
    echo "  Please install wmctrl and xwininfo." && exit 1
  fi
  
  declare -gn pos=$1
  
  if [[ -z $pos ]]; then
    echo "  No such position." && exit 1
  fi
}

get_window_position() {
  if ! source "${state_file}" &>/dev/null || [[ -z "${cur_pos[${!pos}]}" ]]; then
    declare -gA cur_pos
    cur_pos[${!pos}]=0
  fi
}

set_window_geometry() {
  # Unmaximize the window to get proper decoration geometry
  wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz

  # Get decoration geometry
  offsetS=$(xwininfo -id "$(xdotool getactivewindow)" | \
    grep -oP "Relative.*:  \K.*" | tr '\n' ,',')

  x=$(cut -d',' -f1 <<< "${pos[${cur_pos[${!pos}]}]}")
  y=$(cut -d',' -f2 <<< "${pos[${cur_pos[${!pos}]}]}")
  width=$(cut -d',' -f3 <<< "${pos[${cur_pos[${!pos}]}]}")
  height=$(cut -d',' -f4 <<< "${pos[${cur_pos[${!pos}]}]}")
  x_offset=$(cut -d',' -f1 <<< "$offsetS")
  y_offset=$(cut -d',' -f2 <<< "$offsetS")

  # Convert percent to pixels
  [[ $x == *"%" ]] && x=$(( ${x::-1}*screen_width/100 ))
  [[ $y == *"%" ]] && y=$(( ${y::-1}*screen_height/100 ))
  [[ $width == *"%" ]] && width=$(( ${width::-1}*screen_width/100 ))
  [[ $height == *"%" ]] && height=$(( ${height::-1}*screen_height/100 ))

  # Correct windows for menu
  if [[ $menu_position == "top"  && $y -eq 0 ]]; then
    y=$(( y+menu_height ))
    height=$(( height-menu_height ))
  elif [[ $menu_position == "bottom" && ( $height = "$screen_height" || $y -ne 0 ) ]]; then
    height=$(( height-menu_height ))
  fi

  # Correct windows for decorations and gap
  x=$(( x+gap_size ))
  y=$(( y+gap_size ))
  width=$(( width-x_offset*2-gap_size*2 ))
  height=$(( height-x_offset-y_offset-gap_size*2 ))
    
  # Move and resize window
  wmctrl -r :ACTIVE: -e 0,$x,$y,$width,$height
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
get_window_position
set_window_geometry
cycle_window_position

exit 0
