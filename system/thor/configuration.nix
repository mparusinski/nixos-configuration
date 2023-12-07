# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/hosts.nix
      ../common/users.nix
    ];

  # Enable searching for and installing unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" "ntfs" ];

  networking.hostName = "thor"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Paris";
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Handling fonts
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    dejavu_fonts
    vistafonts
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # Hyprland
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.enableHidpi = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "michalparusinski";
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  # Enable sound.
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  users.users.michalparusinski.extraGroups = [ "docker" "video" ];
  users.users.michalparusinski.packages = with pkgs; [
    firefox
    kitty
    blueman
    docker-compose
    git
    light
    distrobox
  ];

  # Setting up bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wofi
    cifs-utils
    xfce.thunar
  ];
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Enable steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # List services that you want to enable:
  services.udisks2.enable = true;  
  virtualisation.docker.enable = true;

  # Setting zswap
  zramSwap = {
    enable = true;
    memoryPercent = 10;
  };

  # Setting BTRBK services
  services.btrbk = {
    instances."home-snapshots" = {
      onCalendar = "hourly";
      settings = {
        snapshot_preserve = "7d";
        snapshot_preserve_min = "2d";
        
        volume."/btr_pool" = {
          snapshot_dir = "snapshots";
          subvolume = "home";
        };
      };
    };
    instances."root-snapshots" = {
      onCalendar = "daily";
      settings = {
        snapshot_preserve = "14d";
        snapshot_preserve_min = "3d";

        volume."/btr_pool" = {
          snapshot_dir = "snapshots";
          subvolume = "root";
        };
      };
    };
  };
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "${pkgs.coreutils-full}/bin/test";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.coreutils-full}/bin/readlink";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.btrfs-progs}/bin/btrfs";
          options = [ "NOPASSWD" ];
        }
      ];
      users = [ "btrbk" ];
    }];
  };

  # Enable network shares
  fileSystems."/media/nassie/public" = {
    device = "//nassie/public";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };
  fileSystems."/media/nassie/snapshots" = {
    device = "//nassie/snapshots";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  networking.firewall = { 
    enable = true;
    allowedTCPPortRanges = [ 
      { from = 1714; to = 1764; } # KDE Connect
    ];  
    allowedTCPPorts = [ 27040 ];
    allowedUDPPortRanges = [ 
      { from = 1714; to = 1764; } # KDE Connect
    ];  
  };  


}

