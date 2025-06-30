{ config, lib, pkgs, ... }:

{
  programs.dconf.enable = true;
  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    asusd = {
      enable = true;
      enableUserService = true;
    };
    openssh.enable = true;
    supergfxd.enable = true;
    flatpak.enable = true;
    libinput.enable = true; # Enable touchpad support
    printing.enable = true;
  };

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
