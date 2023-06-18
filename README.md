# x16-linetest
Line interrupt tests for the Commander X16

To build: run build.sh from a Unix-like shell.

Requires: cc65, python

Tests:
* LINETEST.PRG: 1bpp bitmap 640x480, changing color 1 at line 200 to red
* LT2X.PRG: 2X scale, change at line 200 (line 100 of bitmap)
* LT4X.PRG: 4X scale, change at line 240 (line 60 of bitmap)
* LT8X.PRG: 8x scale, change at line 320 (line 40 of bitmap)
* MODETEST.PRG: change from bitmap to T256 text at line 200, and back to bitmap at 300

Exit any test by hitting 'Q'




