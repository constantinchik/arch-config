#!/usr/bin/env sh

# set variables

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
rofiConf="${confDir}/rofi/selector.rasi"
rofiStyleDir="${confDir}/rofi/styles"
monitorConfigsDir="${confDir}/hypr/monitorconfigs"
monitorConfig="${confDir}/hypr/monitors.conf"
rofiAssetDir="${confDir}/rofi/assets"


# set rofi scaling

[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
elem_border=$(( hypr_border * 5 ))
icon_border=$(( elem_border - 5 ))


# generate config

monitors=("Monitor1" "Monitor2" "Duplicate" "Extend")
col_count=4
r_override="window{width:100%;} listview{columns:${col_count};} element{orientation:vertical;border-radius:${elem_border}px;} element-icon{border-radius:${icon_border}px;size:20em;} element-text{enabled:false;}"

# launch rofi menu

RofiSel=$(ls ${monitorConfigsDir} | grep '.conf$' | cut -d '/' -f2 | cut -d '.' -f1 | while read configName
do
    echo -en "${configName}\x00icon\x1f${monitorConfigsDir}/${configName}.png\n"
done | sort -n | rofi -dmenu -theme-str "${r_override}" -config "${rofiConf}" -select "${rofiStyle}")
# Example output:
# Monitor1icon/home/cost/.config/rofi/assets/style_1.png

# apply monitor display option

if [ ! -z "${RofiSel}" ]; then
    # Your code to apply the selected monitor display option goes here
    notify-send -a "t1" -r 91190 -t 2200 -i "" "Monitor ${RofiSel} selected..." 
    rm ${monitorConfig}
    ln ${monitorConfigsDir}/${RofiSel}.conf ${monitorConfig} -s
fi
