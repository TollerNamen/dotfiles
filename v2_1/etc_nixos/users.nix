{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.admindavid = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "networkmanager"
    ];
    packages = with pkgs; [
      jetbrains-toolbox
      neovim
#      luarocks
#      lua
#      keepassxc
      discord
      tree
      jdk
      gradle
      kotlin
      vscodium
      easyeffects
      tor-browser
#      vala
#      vala-language-server
#      meson
#      ninja
      prismlauncher
      cbonsai
      pipes
      cmatrix
    ];
  };
  #  home-manager.users.admindavid = import ./home config.users.users.admindavid;
}
