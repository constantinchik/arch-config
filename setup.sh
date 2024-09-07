echo "Before running this script make sure that you have an SSH key in github, so that the repositories are cloned without issues."

# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Install hyprland
# sudo pacman -S hyprland

# Install hyprdots
sudo pacman -S git

if [ ! -d "${HOME}/projects" ]; then
    mkdir ${HOME}/projects
fi

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
sudo pacman -S cpio meson cmake hyprwayland-scanner
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm add https://github.com/DreamMaoMao/hycov 
hyprpm enable hycov
hyprpm enable hyprexpo
hyprpm reload

# Copy dotfiles
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
stow . -t ~/.config --adopt
# Remove overrides
cd $SCRIPT_DIR
git checkout .
stow . -t ~/.config --adopt


# Install grub theme
cd /tmp
git clone https://github.com/vinceliuice/grub2-themes.git
sudo /tmp/grub2-themes/install.sh -b -t tela -s 2k

# Install better sddm theme
cd $SCRIPT_DIR
sudo tar -xzvf ./assets/sddm-corners-tweaked.tar.gz -C /usr/share/sddm/themes

# Install other:
# Lutris
flatpak install flathub net.lutris.Lutris
yay -S zen-browser-bin

# Monitors
echo "The monitor configuration is not applied by default. To apply changes simply press SUPER-M and select a preset."
