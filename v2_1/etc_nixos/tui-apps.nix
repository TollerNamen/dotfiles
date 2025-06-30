{ inputPkg, command, displayName }:

let
  pkgs = import <nixpkgs> {};

  configFile = pkgs.writeText "alacritty.toml" ''
    [general]
    import = [
        "/home/admindavid/.config/alacritty/themes/themes/github_dark_high_contrast.toml"
    ]
        #"~/.config/alacritty/midnight-haze.toml"

    [window]
    opacity = 0.6
    blur = true

    [font]
    normal = { family = "JetBrainsMono NF", style = "ExtraBold" }
    size = 20

    [colors.primary]
    background = '#000000'

    [terminal]
    shell = { program = '${pkgs.bash}/bin/bash', args = ['-c', '${command} && exit'] }
  '';

  appName = "${command}-tui-app";

  desktopFile = pkgs.makeDesktopItem {
    name = appName;
    exec = "${pkgs.alacritty}/bin/alacritty --config-file ${configFile}";
    desktopName = displayName;
  };

in pkgs.symlinkJoin {
  name = appName;
  paths = [ inputPkg ];
  postBuild = ''
    mkdir -p $out/share/applications
    cp ${desktopFile}/share/applications/*.desktop $out/share/applications/
  '';
}
