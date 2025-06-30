{ config, lib, nixpkgs, ... }:

{  
  hardware.graphics.enable = true;

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  #nixpkgs.config.allowUnfreePredicate = pkg:
  #  builtins.elem (lib.getName pkg) [
  #    "nvidia-x11"
  #  ];

  hardware.nvidia = {
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    powerManagement = {
      enable = false;
      finegrained = false;
    };
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
  };

  #boot.extraModprobeConfig = ''
  #  blacklist nouveau
  #  options nouveau modeset=0
  #'';
  
  #services.udev.extraRules = ''
  #  # Remove NVIDIA USB xHCI Host Controller devices, if present
  #  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
  #  # Remove NVIDIA USB Type-C UCSI devices, if present
  #  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
  #  # Remove NVIDIA Audio devices, if present
  #  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
  #  # Remove NVIDIA VGA/3D controller devices
  #  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  #'';
  #boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
}
