user: { lib, pkgs, osConfig, ... }:

{
  home = {
    pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };
    username = "${user.name}";
    homeDirectory = "${user.home}";
  };
  gtk = {
    enable = true;
    theme = {
      name = "Nightfox-Dark";
      package = pkgs.nightfox-gtk-theme;
    };
  };
  programs.bash.profileExtra = ''
    export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatp>
  '';
  # The state version is required and should stay at the version >
  # originally installed.
  home.stateVersion = "24.11";
}
