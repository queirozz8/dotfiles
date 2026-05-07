#!/usr/bin/env bash

if pgrep -x "wlogout" >/dev/null; then
    pkill -x "wlogout"
    exit 0
fi

confDir="$HOME/.config/wlogout"
wlogoutStyle=1
wLayout="${confDir}/layout_${wlogoutStyle}"
wlTmplt="${confDir}/style_${wlogoutStyle}.css"

if [ ! -f "${wLayout}" ] || [ ! -f "${wlTmplt}" ]; then
    echo "ERROR: Config ${wlogoutStyle} not found..."
    exit 1
fi

x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale' | sed 's/\.//')

wlColms=6
export mgn=$((y_mon * 28 / hypr_scale))
export hvr=$((y_mon * 23 / hypr_scale))
export fntSize=$((y_mon * 2 / 100))
export BtnCol="white"
export hypr_border="${hypr_border:-10}"
export active_rad=$((hypr_border * 5))
export button_rad=$((hypr_border * 8))

wlStyle="$(envsubst <"${wlTmplt}")"

GTK_THEME=Adwaita wlogout -b "${wlColms}" -c 0 -r 0 -m 0 \
    --layout "${wLayout}" \
    --css <(echo "${wlStyle}") \
    --protocol layer-shell
