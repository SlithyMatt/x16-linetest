#!/bin/sh

python 1bpp_bitmap.py 640_480_grid.data
mv BITMAP.BIN 640GRID.BIN

cl65 -t cx16 -o LINETEST.PRG -l linetest.list --asm-define DISPLAY_SCALE=128 --asm-define CHANGE_LINE=200 linetest.asm
cl65 -t cx16 -o LT2X.PRG -l lt2x.list --asm-define DISPLAY_SCALE=64 --asm-define CHANGE_LINE=200 linetest.asm
cl65 -t cx16 -o LT4X.PRG -l lt4x.list --asm-define DISPLAY_SCALE=32 --asm-define CHANGE_LINE=240 linetest.asm
cl65 -t cx16 -o LT8X.PRG -l lt8x.list --asm-define DISPLAY_SCALE=16 --asm-define CHANGE_LINE=320 linetest.asm

cl65 -t cx16 -o MODETEST.PRG -l layer_mode_test.list layer_mode_test.asm
