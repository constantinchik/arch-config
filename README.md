# Arch Linux with Hyprland installation guide

This repository contains dotfiles. requires to replace the ones that will be
generated after all the steps of installation are completed.

# Arch installation

- Install arch with hyprland and wayland. [Follow this tutorial](https://youtu.be/whAi_y_LfE)
- Install [hyprdots](https://github.com/prasanthrangan/hyprdots) by cloning the repo and running:
  ```bash
  ./install.sh custom_apps.lst
  ```
  Follow the instructions to install everything needed.
- Now go ahead and clone [my dotfiles repository](https://github.com/constantinchik/dotfiles)
  (with --recurse-submodules flag as indicated in the ReadMe) and run the following:
  ```bash
  ./scripts/setup.sh
  ```
  This will install all the required packages as well as symlink all the dotfiles
  configuration to replace the default (or hyprdots) ones.
- Install the hyprland extensions by running the following commands:
  ```bash
    sudo pacman -S cpio meson cmake hyprwayland-scanner
    hyprpm update
    hyprpm add https://github.com/hyprwm/hyprland-plugins
    hyprpm add https://github.com/DreamMaoMao/hycov
    hyprpm enable hycov
    hyprpm enable hyprexpo
  ```
- Afetr this you should have all the required packages installed, go to the root
  of this repository and run
  ```bash
  stow . -t ~
  ```
  to override the default configuration of hyprdots with this custom one.

## Additional steps:

- Install plugins
- To have websites in chrome-based browsers use the catppuccin theme follow [this guide](https://github.com/catppuccin/userstyles)

# Other dotfiles config for Hyprland to consider for future:

- [HyprV4](https://github.com/SolDoesTech/HyprV4)
