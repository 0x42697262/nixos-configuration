# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  # nixpkgs.overlays = [
  #   (
  #     final: prev: {
  #       linuxPackages_latest = prev.linuxPackages_latest.extend (
  #         _lpfinal: _lpprev: {
  #           vmware = prev.linuxPackages_latest.vmware.overrideAttrs (_oldAttrs: {
  #             version = "workstation-17.5.2-k6.9+-unstable-2024-08-22";
  #             src = final.fetchFromGitHub {
  #               owner = "nan0desu";
  #               repo = "vmware-host-modules";
  #               rev = "b489870663afa6bb60277a42a6390c032c63d0fa";
  #               hash = "sha256-9t4a4rnaPA4p/SccmOwsL0GsH2gTWlvFkvkRoZX4DJE=";
  #             };
  #           });
  #         }
  #       );
  #     }
  #   )
  # ];

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.grub.device = "/dev/vda";
  #boot.loader.grub.efiSupport = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  hardware.enableAllFirmware = true;

  boot.supportedFilesystems = [ "btrfs" ];
  boot.tmp.useTmpfs = true;


  fileSystems."/" =
    {
      options = [ "subvol=root" "compress=zstd:3" "discard=async" "noatime" "ssd" "space_cache=v2" ];
    };


  fileSystems."/home" =
    {
      options = [ "compress=zstd:3" "relatime" "discard=async" "ssd" "space_cache=v2" ];
    };

  fileSystems."/nix" =
    {
      options = [ "subvol=nix" "compress=zstd:3" "discard=async" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/persist" =
    {
      options = [ "subvol=persist" "compress=zstd:3" "discard=async" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/var/log" =
    {
      options = [ "subvol=log" "compress=zstd:3" "discard=async" "noatime" "ssd" "space_cache=v2" ];
      neededForBoot = true;
    };

  fileSystems."/birb" =
    {
      options = [ "compress=zstd:3" "discard=async" "relatime" "ssd" "space_cache=v2" ];
    };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /mnt
    mount -t btrfs /dev/mapper/root /mnt
    btrfs subvolume delete /mnt/root
    btrfs subvolume snapshot /mnt/root-clean /mnt/root
  '';

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "AtomicBird"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chewing
      fcitx5-mozc
    ];

  };





  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # services.printing.drivers = [ pkgs.epson_201207w ];
  services.tailscale.enable = true;

  # hardware.printers = {
  #
  #   ensurePrinters = [
  #     {
  #
  #       name = "EPSON_L120_Series";
  #       location = "Local Printer";
  #       deviceUri = "usb://EPSON/L120%20Series?serial=5450334B4232373696";
  #       model = "";
  #       ppdOptions = {
  #         PageSize = "A4";
  #       };
  #     }
  #   ];
  #   ensureDefaultPrinter = "EPSON_L120_Series";
  # };
  # Enable sound.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  users.defaultUserShell = pkgs.fish;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.birb = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "networkmanager"
      "docker"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      android-studio
      anki
      antora
      asciidoc-full-with-plugins
      asciidoctor-with-extensions
      dunst
      fishPlugins.tide
      gcc
      grimblast
      lazygit
      lxqt.lxqt-policykit
      lynx
      metasploit
      mpv
      neofetch
      nvtop
      obs-studio
      openssl
      pavucontrol
      rofi
      slurp
      texliveFull
      tigervnc
      thunderbird
      tree
      typst
      udiskie
      vesktop
      vlc
      waybar
      wget
      zathura
    ];
  };

  programs.hyprland = {
    enable = true;
    # xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];
  };
  programs.firejail = {
    enable = true;

    wrappedBinaries = {

      osu = {
        executable = "${pkgs.osu-lazer-bin}/bin/osu!";
        extraArgs = [
          "--private=~/firejail"
          "--noprofile"
        ];
      };
      # steam = {
      #   executable = "${pkgs.steam}/bin/steam";
      #   extraArgs = [
      #     "--private=~/firejail"
      #     "--noprofile"
      #   ];
      # };
      chromium = {
        executable = "${pkgs.chromium}/bin/chromium";
        extraArgs = [
          "--private=~/firejail"
          "--noprofile"
        ];
      };

      appimage-run = {
        executable = "${pkgs.appimage-run}/bin/appimage-run";
        extraArgs = [
          "--private=~/firejail"
          "--noprofile"
        ];
      };

      geekbench = {
        executable = "${pkgs.geekbench}/bin/geekbench6";
        extraArgs = [
          "--private=~/firejail"
          "--noprofile"
        ];
      };
    };
  };

  environment.shellAliases = {
    ls = "lsd -la";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    "......" = "cd ../../../../..";
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      #cpupower
      acpilight
      btop
      firefox
      git
      gparted
      htop
      kitty
      lsd
      ncdu
      neovim
      nmap
      openvpn
      pciutils
      pkgs.linuxKernel.packages.linux_latest_libre.cpupower
      unzip
      usbutils
      vim
      w3m
      wireguard-tools
      wireplumber
      wl-clipboard-rs
      zstd
    ];

  fonts.packages = with pkgs; [
    meslo-lgs-nf
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    vistafonts
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  hardware.nvidia-container-toolkit.enable = true;
  hardware.bluetooth.enable = true;

  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };

  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    prime.amdgpuBusId = "PCI:0:6:0";
    prime.nvidiaBusId = "PCI:0:1:0";
    prime.offload = {
      enable = true;
      enableOffloadCmd = true;
    };
  };

  services.fwupd.enable = true;
  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
  services.blueman.enable = true;
  services.udisks2.enable = true;
  # services.desktopManager.cosmic.enable = true;
  # services.displayManager.cosmic-greeter.enable = true;
  # List services that you want to enable:
  # services.automatic-timezoned.enable = true;
  services.timesyncd.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  systemd.services = {
    sshd = {
      wantedBy = lib.mkForce [ ];
    };
    NetworkManager-wait-online.wantedBy = lib.mkForce [ ];
    vmware-networks.wantedBy = lib.mkForce [ ];
  };

  boot.extraModprobeConfig = "options kvm_amd nested=1";
  # boot.extraModprobeConfig = ''
  #   blacklist nouveau
  #   options nouveau modeset=0
  # '';
  #
  # services.udev.extraRules = ''
  #   # Remove NVIDIA USB xHCI Host Controller devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
  #   # Remove NVIDIA USB Type-C UCSI devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
  #   # Remove NVIDIA Audio devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
  #   # Remove NVIDIA VGA/3D controller devices
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  # '';
  # boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];


  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    storageDriver = "btrfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  virtualisation.waydroid.enable = true;

  virtualisation.vmware.host = {
    enable = true;
  };
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
    enableKvm = true;
    addNetworkInterface = false;
  };
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
    allowedBridges = [
      "nm-bridge"
      "virbr0"
    ];
  };
  programs.virt-manager = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_greeting
    '';
    shellAbbrs = {
      Ns = "nix-shell -p --command fish";
      Nd = "nix develop";
    };
  };

  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    # localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  zramSwap.enable = true;

  security.polkit.enable = true;


  # networking.nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  #
  # services.resolved = {
  #   enable = true;
  #   dnssec = "true";
  #   domains = [ "~." ];
  #   fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  #   dnsovertls = "true";
  # };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 6969 ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
