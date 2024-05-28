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

# Override default config of hyprdots with this custom one from this repo
cd $SCRIPT_DIR
stow . -t ~/.config --adopt


# Install other:
# Lutris
flatpak install flathub net.lutris.Lutris
