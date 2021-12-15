#!/bin/bash

# tilex.sh - Bash script that moves windows to preset positions in X.
# Most useful if configured to be launched with keyboard shortcuts.
# 
# Tested with XFCE with default positions for 3440x1440.
# Example: ./tilex.sh left

# General settings
SCREEN_WIDTH=3440
SCREEN_HEIGHT=1440
MENU_HEIGHT=33
GAP_SIZE=3
STATE_FILE=/tmp/tilex.tmp

# Window positions (X, Y, WIDTH, HEIGHT)
left_top[0]=0%,0%,30%,50%
left[0]=0%,0%,30%,100%
left[1]=0%,0%,50%,100%
left_bottom[0]=0%,50%,30%,50%
center_top[0]=0%,0%,100%,50%
center[0]=30%,0%,40%,100%
center[1]=0%,0%,100%,100%
center_bottom[0]=0%,50%,100%,50%
right_top[0]=70%,0%,30%,50%
right[0]=70%,0%,30%,100%
right[1]=50%,0%,50%,100%
right_bottom[0]=70%,50%,30%,50%

check_requirements() {
  if [ $# -ne 1 ]; then
    echo -e "  Usage: $0 \e[3mposition\e[0m" && exit 1
  fi 
  
  if ! command -v wmctrl &>/dev/null || ! command -v xwininfo &>/dev/null; then
    echo "  Please install wmctrl and xwininfo." && exit 1
  fi
  
  declare -gn POS=$1
  
  if [ -z $POS ]; then
    echo "  No such position." && exit 1
  fi
}

function get_window_position() {
  if ! source "${STATE_FILE}" &>/dev/null || [ -z "${CUR_POS[${!POS}]}" ]; then
    declare -gA CUR_POS
    CUR_POS[${!POS}]=0
  fi
}

function set_window_geometry() {
  # Unmaximize the window to get proper decoration geometry
  wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz

  # Get decoration geometry
  OFFSETS=$(xwininfo -id "$(xdotool getactivewindow)" | \
    grep -oP "Relative.*:  \K.*" | tr '\n' ,',')

  X=$(cut -d',' -f1 <<< "${POS[${CUR_POS[${!POS}]}]}")
  Y=$(cut -d',' -f2 <<< "${POS[${CUR_POS[${!POS}]}]}")
  WIDTH=$(cut -d',' -f3 <<< "${POS[${CUR_POS[${!POS}]}]}")
  HEIGHT=$(cut -d',' -f4 <<< "${POS[${CUR_POS[${!POS}]}]}")
  X_OFFSET=$(cut -d',' -f1 <<< "$OFFSETS")
  Y_OFFSET=$(cut -d',' -f2 <<< "$OFFSETS")

  # Convert percent to pixels
  [[ $X == *"%" ]] && X=$(( ${X::-1}*SCREEN_WIDTH/100 ))
  [[ $Y == *"%" ]] && Y=$(( ${Y::-1}*SCREEN_HEIGHT/100 ))
  [[ $WIDTH == *"%" ]] && WIDTH=$(( ${WIDTH::-1}*SCREEN_WIDTH/100 ))
  [[ $HEIGHT == *"%" ]] && HEIGHT=$(( ${HEIGHT::-1}*SCREEN_HEIGHT/100 ))
    
  # Correct top windows for menu height
  if [[ $Y -eq 0 ]]; then
    Y=$(( Y+MENU_HEIGHT ))
    HEIGHT=$(( HEIGHT-MENU_HEIGHT ))
  fi

  # Correct all windows for decorations and gap
  X=$(( X+GAP_SIZE ))
  Y=$(( Y+GAP_SIZE ))
  WIDTH=$(( WIDTH-X_OFFSET*2-GAP_SIZE*2 ))
  HEIGHT=$(( HEIGHT-X_OFFSET-Y_OFFSET-GAP_SIZE*2 ))
    
  # Move and resize window
  wmctrl -r :ACTIVE: -e 0,$X,$Y,$WIDTH,$HEIGHT
}

function cycle_window_position() {
  if [ "${CUR_POS[${!POS}]}" -lt $(( ${#POS[@]}-1 )) ]; then
    (( CUR_POS[${!POS}]++ ))
  else
    CUR_POS[${!POS}]=0
  fi

  declare -Ap CUR_POS | sed 's/ -[aA]/&g/' > ${STATE_FILE}
}

check_requirements $1
get_window_position
set_window_geometry
cycle_window_position

exit 0
