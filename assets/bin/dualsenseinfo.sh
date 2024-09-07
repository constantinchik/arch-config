#!/usr/bin/env sh

status=$(dualsensectl battery 2> /dev/null)
perc=$(echo $status | cut -d' ' -f1)
state=" $(echo $status | cut -d' ' -f2)%"

if [ -z "$status" ]; then
    # Controller is not connected
    # icon="󰊵"
    echo "{\"text\": \"\"}"
    exit
elif [ "${state}" = "charging" ]; then
    icon="󰨢"
elif [ "$perc" -le 10 ]; then
    icon="󰝌"
elif [ "$perc" -le 30 ]; then
    icon="󰝎"
elif [ "$perc" -le 80 ]; then
    icon="󰝏"
elif [ "$perc" -le 100 ]; then
    icon="󰝍"
fi

echo $icon
echo "{\"text\":\"${icon} ${perc}%\", \"tooltip\":\"Dualsense controller\"}"

# case $state in
#   *charging*)
#     is_charging=true
#     icon_value="󰨢" ;;
#   *discharging*)
#     is_charging=false
#     icon_value="\\uf2ae" ;;
#   *)
#     charge_type="Unknown"
#     icon_value="\\uf2ae" ;;
# esac
#
#
# echo $is_charging
