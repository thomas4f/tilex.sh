# tilex.sh
Bash script that moves windows to preset positions in X.

![tilex](https://user-images.githubusercontent.com/51061686/146162894-2e70d505-ae69-47b6-8b0b-2188b2d95742.png)

## Description
tilex.sh is a small batch script that allows you to effortlessly position windows in X.

It supports gaps, presets configured either in pixels or percent, and cycling through multiple presets.

The script should (hopefully) properly account for window decorations, title bars and ensure that windows do not overlap.

## How to use
1. First, configure your screen width, height, menu height and preferred gap size. 
2. Next, configure your window position presets as arrays, with X, Y, width and height values separated by commas.
3. Finally, invoke the script, with the desired position as the only argument. 

Typically, you'd invoke the script it by keyboard shortcuts, for example ``Super + num7`` to cycle between left_top positions, ``Super + num5`` for center positions, etc.

## Example usage
```console
./tilex.sh left
```

## Credits
- Credits to [Colin Keenan](https://unix.stackexchange.com/a/156349) for hints on how to properly account for decorations.
- The cycling feature was inspired by [WinSplit](https://github.com/dozius/winsplit-revolution).
