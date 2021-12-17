# tilex.sh
Bash script that moves windows to preset positions in X.

![tilex](https://user-images.githubusercontent.com/51061686/146513147-47c57845-53ec-4d5b-b29d-2740655de9d4.gif)

## Description
tilex.sh is a leight weight shell script that allows you to effortlessly create grids to position/tile windows in X.

It supports gaps, presets configured either in pixels or in percent, and cycling through multiple presets.

The script should (hopefully) properly account for window decorations, title bars and ensure that windows do not overlap.

## How to use
1. First, configure your screen width and height, menu position and it's size, as well as your preferred gap size. 
2. Next, configure your window position presets as arrays, with X, Y, width and height values separated by commas.
3. Finally, invoke the script with the desired position as the first argument. Optionally provide an index to set it directly rather than cycling. 

Typically, you'd invoke the script it by keyboard shortcuts, for example ``Super + num7`` to cycle between left_top positions, ``Super + num5`` for center positions, etc.

## Example usage
```console
./tilex.sh left
```

## Requirements
``wmctrl`` and ``xprop``. Both seem to be available in most package repositories. For example:

```console
# Arch Linux
pacman -S wmctrl xorg-xprop

# Debian and derivatives
apt install wmctrl x11-utils
```
## Customization
Here are some presets inspired by [PowerToys FancyZones](https://docs.microsoft.com/en-us/windows/powertoys/fancyzones):
### 3 columns
```console
# 3 Columns
left[0]=0%,0%,33%,100%
center[0]=33%,0%,34%,100%
right[0]=67%,0%,33%,100%
```

### 3 rows
```console
# 3 Rows
top[0]=0%,0%,100%,33%
center[0]=0%,33%,100%,34%
bottom[0]=0%,67%,100%,33%
```
### 4x4
```console
# 4x4
top_left[0]=0%,0%,50%,50%
bottom_left[0]=0%,50%,50%,50%
top_right[0]=50%,0%,50%,50%
bottom_right[0]=50%,50%,50%,50%
```

### Priority grid
```console
# Priority grid
left[0]=0%,0%,30%,100%
center[0]=33%,0%,40%,100%
top_right[0]=70%,0%,30%,50%
bottom_right[0]=70%,50%,30%,50%
```

## Caveats
- Some environments (such as Ubuntu/Gnome) use decorations with massive shadows that increase the frame extents, effectively creating huge gaps between windows.
- Also, there's no nice way to account for multiple menus/sidebars.

Feel free to fix this yourself, for example by experimenting with the extent variables (``extent_left``, ``extent_right``, etc). Create a PR if you find a nice solution!



## Credits
- Credits to [Colin Keenan](https://unix.stackexchange.com/a/156349) for hints on how to properly account for decorations.
- The cycling feature was inspired by [WinSplit](https://github.com/dozius/winsplit-revolution).

_It's not exactly FancyZones, but it gets the job done! :)_
