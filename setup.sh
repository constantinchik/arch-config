echo "Before running this script make sure that you have an SSH key in github, so that the repositories are cloned without issues."

# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Install hyprland
sudo pacman -S hyprland

# Install hyprdots
pacman -Sy git
if [ ! -d "~/projects/hyprdots" ]; then
    mkdir ~/projects
    cd ~/projects/
    git clone --depth 1 https://github.com/prasanthrangan/hyprdots
    cd /hyprdots/Scripts
    ./install.sh custom_apps.lst
else
    cd ~/projects/hyprdots
    git fetch
    git pull
    ./install.sh -r
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
if [ ! -d "~/projects/dotfiles" ]; then
    cd ~/projects/
    git clone --recurse-submodules git@github.com:constantinchik/dotfiles.git
    cd dotfiles/
    ./scripts/setup.sh
else
    cd ~/projects/dotfiles
    git fetch
    git pull
    ./scripts/setup.sh
fi

# Copy additional custom scripts
cp -a ${SCRIPT_DIR}/assets/bin/. ${HOME}/.local/share/bin

# Override default config of hyprdots with this custom one from this repo
cd $SCRIPT_DIR
stow . -t ~/.config --adopt
# Remove overrides
git checkout .
stow . -t ~/.config --adopt


# Install grub theme
cd /tmp
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
sudo ./install.sh -b -t tela -s 2k

# Install better sddm theme
cd $SCRIPT_DIR
sudo tar -xzvf ./assets/sddm-corners-tweaked.tar.gz -C /usr/share/sddm/themes

# Install other:
# Lutris
flatpak install flathub net.lutris.Lutris
pacman -S chromium

# Monitors
echo "The monitor configuration is not applied by default. To apply changes simply press SUPER-M and select a preset."
