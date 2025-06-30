{ config, lib, pkgs, ... }:

let
  unstable = import <nixos-unstable> {};

  colloid-dark = pkgs.colloid-gtk-theme.override {
    tweaks = [ "black" ];
  };

  patchDesktop = with pkgs; pkg: appName: from: to:
    lib.hiPrio (
      pkgs.runCommand "$patched-desktop-entry-for-${appName}" {} ''
        ${coreutils}/bin/mkdir -p $out/share/applications
        ${gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      ''
    );

  GPUOffloadXApp = with pkgs; pkg: desktopName:
    patchDesktop pkg desktopName "^Exec=" "Exec=nvidia-offload env -u WAYLAND_DISPLAY ";

  tuiAppDesktop = import ./tui-apps.nix;
in
{
  imports = [
    ./.
    #"${unstableModules}/nixos/modules/programs/steam.nix"
  ];
  #disabledModules = [ "programs/steam.nix" ];

  boot = {
    loader = {
      systemd-boot = {
	enable = true;
	consoleMode = "max";
	configurationLimit = 10;
	editor = false;
      };
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
    kernelParams = [
      "atkbd.reset=1"
      "i8042.nomux=1"
      "i8042.reset=1"
      "i8042.nopnp=1"
      "i8042.dumbkbd=1"
      "quiet"
      "splash"
    ];
    supportedFilesystems = [ "ntfs" ];
  };

  time.timeZone = "Europe/Berlin";

  console.keyMap = "de";
  i18n.defaultLocale = "en_US.UTF-8";
  lib.mkDefault.console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
    useXkbConfig = true; # use xkb.options in tty.
  };

  nix.extraOptions = ''
    trusted-users = root admindavid
  '';

  #services.xserver.enable = true;

  # Configure keymap in X11
  #services.xserver.xkb.layout = "de";
  #services.xserver.xkb.options = "eurosign:e,caps:escape";

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

#  home-manager.useGlobalPkgs = true;

  environment.variables = {
    GTK_THEME = "Colloid-Dark";
    QT_STYLE_OVERRIDE = "kvantum";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1.7";
  };

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    nix-output-monitor
#    wpa_supplicant_gui
#    vim
    wget
#    grim
#    slurp
    wl-clipboard
    mako
    flatpak
    alacritty
    alacritty-theme
    git
    mpv
    geeqie
    playerctl
    brightnessctl
    pulseaudio
#    glib
    fastfetch
    killall
    inxi
    firefox
    (tuiAppDesktop {
      inputPkg = btop;
      command = "btop";
      displayName = "BashTop";
    })
    (tuiAppDesktop {
      inputPkg = bluetuith;
      command = "bluetuith";
      displayName = "Bluetuith";
    })
    (tuiAppDesktop {
      inputPkg = cava;
      command = "cava";
      displayName = "Cava";
    })
    libnotify
    starship
    lm_sensors
    fzf
    tldr
#    gtk4
    nautilus
#    atuin
#    powertop
#    z-lua
    dust
    bat
#    zellij
    eza
    fuzzel
    shotman
    nightfox-gtk-theme
    colloid-dark
#    ungoogled-chromium
    morewaita-icon-theme
    waybar
    wttrbar
    greetd.regreet
#    nvtopPackages.nvidia
    (GPUOffloadXApp steam "steam")
    swayosd
    adwsteamgtk
    bubblewrap
    better-control
  ];

  # SWAY
  services.gnome.gnome-keyring.enable = true;

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      package = pkgs.swayfx;
      extraSessionCommands = ''
        # SDL:
        export SDL_VIDEODRIVER=wayland
        # QT (needs qt5.qtwayland in systemPackages):
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      extraPackages = with pkgs; [
        brightnessctl
#        grim
        pulseaudio
        swayidle
        swaylock
       ];
      extraOptions = [
        "--unsupported-gpu"
      ];
    };
    regreet = {
      theme = {
        package = colloid-dark;
        name = "Colloid-Dark";
      };
      font = {
        name = "JetBrainsMono NF ExtraBold";
        size = 20;
      };
      settings.background.path = "/etc/nixos/wallpapers/wallhaven-p9dpgp.jpg";
      enable = true;
    };
    steam.enable = true;
    light.enable = true;
    thunar.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      pango
      jetbrains-mono
      nerd-fonts.jetbrains-mono
#      font-awesome
#      powerline-fonts
#      powerline-symbols
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
#      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Noto Sans" "Source Han Sans" ];
    };
  };

  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi'';
    };
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      #command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'sway --unsupported-gpu'";
      command = "${pkgs.swayfx}/bin/sway --unsupported-gpu --config /etc/greetd/sway-config";
      user = "greeter";
    };
  };

  environment.etc."greetd/sway-config".text = ''
    exec "regreet; swaymsg exit"
    input type:keyboard {
      xkb_layout "de"
    }
    input type:touchpad {
      dwt enabled
      tap enabled
      natural_scroll enabled
      middle_emulation enabled
    }
    include /etc/sway/config.d/*
  '';

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
  
  # beta stuff
  #nix.settings.substituters = [ 
  #  # "https://aseipp-nix-cache.global.ssl.fastly.net"
  #  "https://cache.nixos.org"
  #];
}
