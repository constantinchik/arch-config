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

prepare_lutris_games() {
    meta_data="/tmp/hyprdots-$(id -u)-lutrisgames.json"

    eval "${run_lutris}" -j -l 2> /dev/null | jq --arg icons "$icon_path/" --arg prefix ".jpg" '.[] |= . + {"select": (.name + "\u0000icon\u001f" + $icons + .slug + $prefix)}' > "${meta_data}"
    jq -r '.[].select' "${meta_data}"
}

# Unified launcher
launch_games() {
    steam_games=$(prepare_steam_games)
    lutris_games=$(prepare_lutris_games)

    # Ensure both lists are properly newline-separated and combined
    all_games=$(echo -e "$(prepare_steam_games)\n$(prepare_lutris_games)")
    print $all_games

    # Launch Rofi with formatted entries
    choice=$({
        prepare_steam_games
        prepare_lutris_games
    } | rofi -dmenu -p "Games" -theme-str "$r_override" -config $RofiConf)

    # Parse the choice for launch details
    game_name=$(echo "$choice" | cut -d $'\x00' -f 1)
    game_type=$(echo "$choice" | grep -oE 'steam|lutris')
    icon_path=$(echo "$choice" | grep -oP '(?<=icon\x1f).*(?=.jpg)' | sed 's/\.jpg//')

    case $game_type in
        steam)
            launchid=$(echo "$icon_path" | awk -F'/' '{print $NF}')  # Extract appid from path
            notify-send "Launching $game_name..."
            steam -applaunch $launchid &
            ;;
        lutris)
            slug=$(echo "$icon_path" | awk -F'/' '{print $NF}')
            notify-send "Launching $game_name..."
            xdg-open "lutris:rungame/$slug"
            ;;
    esac
}

# Detect if flatpak or native versions of Lutris are installed
run_lutris=""
( flatpak list --columns=application | grep -q "net.lutris.Lutris" ) && run_lutris="flatpak run net.lutris.Lutris" ; icon_path="${HOME}/.var/app/net.lutris.Lutris/data/lutris/coverart/"
[ -z "$run_lutris" ] && ( command -v lutris > /dev/null ) && run_lutris="lutris"

# Execute the launcher
launch_games

