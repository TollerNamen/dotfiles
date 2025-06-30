# Welcome to my dotfiles
Seems like you stumbled across my configuration files. Have following along my very little ricing story on NixOS using SwayFx and Waybar.

## History

<details>
  <summary>Version 1: First Try</summary>
  <p>First up with blue primary color, it is my first real try of ricing, which is why i dropped it mid completion in favour for v2.</p>
  
  
![Screenshot](v1/preview.png)

</details>

<details>
  <summary>Version 2: Current</summary>
  <p>This is my second try, you may see that the files from the sway, fuzzel directories and waybar/config.jsonc are mostly if not the same compared to v1.
  With more experience i could get more working and i decided to go for a simple style setup, especially for waybar.</p>

![Screenshot](v2/preview.png)

  <p>You will see that the NixOS configuration changed quite a lot...</p>

```
v2/etc_nixos
├── channels.nix
├── configuration.nix
├── default.nix
├── general
│   ├── default.nix
│   ├── graphics.nix
│   ├── network.nix
│   └── services.nix
├── hardware-configuration.nix
├── home
│   └── default.nix
├── tui-apps.nix
├── users.nix
└── wallpapers
    └── wallhaven-p9dpgp.jpg
```
  <p>That is because I modularised it, setup the plan for migrating to home-manager, setup nvidia graphics for my main computer and installed for example steam for gaming and regreet as an alternative to tuigreet.</p>
</details>


