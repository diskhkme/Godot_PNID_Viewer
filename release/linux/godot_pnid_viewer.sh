#!/bin/sh
echo -ne '\033c\033]0;PNID_Viewr_GUI\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/godot_pnid_viewer.x86_64" "$@"
