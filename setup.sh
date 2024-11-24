# echo "Before running this script make sure that you have an SSH key in github, so that the repositories are cloned without issues."

echo "Installing packages..."
# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

./src/install-packages.sh

# Make sure ~/project exists
if [ ! -d "${HOME}/projects" ]; then
    mkdir ${HOME}/projects
fi

# Install hyprdots
if [ ! -d "${HOME}/projects/hyprdots" ]; then
    cd ${HOME}/projects
    git clone --depth 1 https://github.com/prasanthrangan/hyprdots
    ${HOME}/projects/hyprdots/Scripts/install.sh ${HOME}/projects/hyprdots/Scripts/custom_apps.lst
else
    cd ${HOME}/projects/hyprdots
    git fetch
    git pull
    ${HOME}/projects/hyprdots/Scripts/install.sh ${HOME}/projects/hyprdots/Scripts/custom_apps.lst -r
fi

# Install hyprland extensions
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
## COMMENT-REASON: Does not work
# hyprpm add https://github.com/DreamMaoMao/hycov 
# hyprpm enable hycov
hyprpm enable hyprexpo
hyprpm reload

# Ensure/Download my dotfiles and install them
if [ ! -d "${HOME}/projects/dotfiles" ]; then
    cd ${HOME}/projects/
    git clone --recurse-submodules git@github.com:constantinchik/dotfiles.git
    ${HOME}/projects/dotfiles/scripts/setup.sh
else
    cd ${HOME}/projects/dotfiles
    git fetch
    git pull
    ${HOME}/projects/dotfiles/scripts/setup.sh
fi

# Copy additional custom scripts
cp -a ${SCRIPT_DIR}/assets/bin/. ${HOME}/.local/share/bin

# Override default config of hyprdots with this custom one from this repo
cd $SCRIPT_DIR
# Protect current config from being overriden
git add -A
# Symlink dotfiles
stow . -t ~/.config --adopt
# Remove overrides (^try remove adopt here)
git checkout .

# Install grub theme
cd /tmp
git clone https://github.com/vinceliuice/grub2-themes.git
sudo /tmp/grub2-themes/install.sh -b -t tela -s 2k

## COMMENT-REASON: USE GNOME GREETER
# Install better sddm theme
# cd $SCRIPT_DIR
# sudo tar -xzvf ./assets/sddm-corners-tweaked.tar.gz -C /usr/share/sddm/themes

# Install other:
# Lutris
flatpak install flathub net.lutris.Lutris

# Setup monitors
read -p "Do you want to setup constantine's monitor setup (Y/n): " answer
answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
if [[ "$answer" == "Y" || "$answer" == "YES" || "$answer" == "" ]]; then
    echo "Installing default mirror profile"
    ln -sf ${SCRIPT_DIR}/mirror.conf ${HOME}/.config/hypr/monitors.conf
else
    echo "Skipped installing monitor configs."
fi

echo "Done!"
