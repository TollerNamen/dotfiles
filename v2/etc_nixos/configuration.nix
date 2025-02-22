{ config, lib, pkgs, ... }:

let
  unstable = import <nixos-unstable> {};
  unstableModules = <nixos-unstable>;

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
      systemd-boot.enable = true;
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

  #services.xserver.enable = true;

  # Configure keymap in X11
  #services.xserver.xkb.layout = "de";
  #services.xserver.xkb.options = "eurosign:e,caps:escape";

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  home-manager.useGlobalPkgs = true;

  environment.variables = {
    GTK_THEME = "Colloid-Dark";
    QT_STYLE_OVERRIDE = "kvantum";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1.7";
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    nix-output-monitor
    wpa_supplicant_gui
    vim
    wget
    grim
    slurp
    wl-clipboard
    mako
    flatpak
    alacritty
    alacritty-theme
    jdk
    git
    haskellPackages.random
    vlc
    geeqie
    playerctl
    brightnessctl
    pulseaudio
    glib
    fastfetch
    killall
    inxi
    firefox
    (tuiAppDesktop {
      inputPkg = btop;
      command = "btop";
      displayName = "BashTop";
    })
#    btop
    starship
    #tofi
    lm_sensors
    fzf
    tldr
    gtk4
    nautilus
    atuin
    powertop
    z-lua
    dust
    bat
    zellij
    eza
    fuzzel
    (tuiAppDesktop {
      inputPkg = bluetuith;
      command = "bluetuith";
      displayName = "Bluetuith";
    })
#    bluetuith
    shotman
    unstable.swayrbar
    nightfox-gtk-theme
    colloid-dark
    ungoogled-chromium
    morewaita-icon-theme
    waybar
    greetd.regreet
    nvtopPackages.full
    (GPUOffloadXApp steam "steam")

    # later in home manager
    adwsteamgtk
    bubblewrap
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
        grim
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
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      font-awesome
      powerline-fonts
      powerline-symbols
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
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
