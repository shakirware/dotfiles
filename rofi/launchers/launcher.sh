#!/usr/bin/env bash

dir="$HOME/.config/rofi/styles"
theme='style-1'

## Run
rofi -show drun \
-theme $dir/"$theme"
