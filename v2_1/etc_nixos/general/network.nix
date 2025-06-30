{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "nixos-asus";

    wireless = {
      networks = {
        # omitted network data
      };
      enable = true;
      userControlled.enable = true;
    };

    networkmanager = {
      enable = true;
      unmanaged = [
        "*" "except:type:wwan" "except:type:gsm"
      ];
    };

    # Configure network proxy if necessary
    #proxy.default = "http://user:password@proxy:port/";
    #proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    #firewall.allowedTCPPorts = [ ... ];
    #firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    #firewall.enable = false;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  services = {
    pipewire.wireplumber.extraConfig."11-bluetooth-policy" = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };
    blueman.enable = true;
  };

  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };
}
