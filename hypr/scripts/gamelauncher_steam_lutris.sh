#!/usr/bin/env sh

# Set variables
MODE=${1:-5}
ScrDir=`dirname "$(realpath "$0")"`
source $ScrDir/globalcontrol.sh
ThemeSet="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/themes/theme.conf"
RofiConf="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/steam/gamelauncher_${MODE}.rasi"

# Set Rofi override
elem_border=$(( hypr_border * 2 ))
icon_border=$(( elem_border - 3 ))
r_override="element{border-radius:${elem_border}px;} element-icon{border-radius:${icon_border}px;}"

SteamRoot="$HOME/.local/share/Steam"
icon_path="${HOME}/.local/share/lutris/coverart"

# Prepare list functions
prepare_steam_games() {
    SteamLib="$SteamRoot/config/libraryfolders.vdf"
    SteamThumb="$SteamRoot/appcache/librarycache"
    SteamPaths=$(grep '"path"' $SteamLib | awk -F '"' '{print $4}')
    ManifestList=$(find $SteamPaths/steamapps/ -type f -name "appmanifest_*.acf" 2>/dev/null)

    echo "$ManifestList" | while read acf; do
        appid=$(grep '"appid"' $acf | cut -d '"' -f 4)
        if [ -f "${SteamThumb}/${appid}_library_600x900.jpg" ]; then
            game=$(grep '"name"' $acf | cut -d '"' -f 4)
            echo -en "$game\x00icon\x1f${SteamThumb}/${appid}_library_600x900.jpg\n"
        fi
    done | sort
}

# Function to fetch Lutris games
prepare_lutris_games() {
    meta_data="/tmp/hyprdots-$(id -u)-lutrisgames.json"

    eval "${run_lutris}" -j -l 2> /dev/null | jq --arg icons "$icon_path/" --arg prefix ".jpg" '.[] |= . + {"select": (.name + " (Lutris)\u0000icon\u001f" + $icons + .slug + $prefix)}' > "${meta_data}"
    jq -r '.[].select' "${meta_data}"
}

# Combined function to launch Rofi with games from both sources
launch_games() {
    RofiSel=$({
        prepare_steam_games
        prepare_lutris_games
    } | rofi -dmenu -p "Games" -theme-str "$r_override" -config $RofiConf)
    
    if [ -n "$RofiSel" ]; then
        if [[ "$RofiSel" == *"/(Steam)/"* ]]; then
            appid=$(basename "${icon_path%_library_600x900.jpg}")
            notify-send -a "t1" -i "${icon_path}" "Launching ${RofiSel}..."
            steam -applaunch $appid &
        elif [[ "$RofiSel" == *"(Lutris)"* ]]; then
            slug=$(basename "${icon_path%.jpg}")
            notify-send -a "t1" -i "${icon_path}" "Launching ${RofiSel}..."
            xdg-open "lutris:rungame/$slug"
        else
            echo "Error determining game source."
        fi
    fi
}

# Determine if flatpak or native versions of Lutris are installed
run_lutris=""
( flatpak list --columns=application | grep -q "net.lutris.Lutris" ) && run_lutris="flatpak run net.lutris.Lutris" ; icon_path="${HOME}/.var/app/net.lutris.Lutris/data/lutris/coverart/"
[ -z "$run_lutris" ] && ( command -v lutris > /dev/null ) && run_lutris="lutris"

# Execute the game launcher
launch_games

