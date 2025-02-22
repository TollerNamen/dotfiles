{ config, lib, pkgs, ... }:

{
  users.users.admindavid = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
    ];
    packages = with pkgs; [
      keepassxc
      discord
      tree
      jetbrains.idea-community
      vscodium
      easyeffects
      tor-browser
      vala
      vala-language-server
      meson
      ninja
      prismlauncher
    ];
  };
  home-manager.users.admindavid = import ./home config.users.users.admindavid;
}
