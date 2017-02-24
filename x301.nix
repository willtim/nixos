#
# x301 server config
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./common.nix
    ];

  boot.kernelModules            = [ "tp_smapi" "kvm-intel" ];
  boot.extraModulePackages      = [ config.boot.kernelPackages.tp_smapi ];
  boot.blacklistedKernelModules = [ "pcspkr" ];
  boot.supportedFilesystems     = [ "zfs" ];

  boot.initrd.kernelModules = [
   # Specify all kernel modules that are necessary for mounting the root
   # file system.
   "fbcon" "vfat" "i915" "aesni-intel" "usb_storage" "ehci_pci" "uhci_hcd" "ahci"
  ];

  # Legacy BIOS booting
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # File systems
  # explicitly configure fileSystems here, not in hardware-configuration.nix
  fileSystems."/" = {
    label = "root";
    device = "/dev/sda1";
    fsType = "xfs";
    options = ["discard" "noatime"];
  };
  swapDevices = [ { device = "/dev/sda2"; } ];

  # zfs legacy-style mounts
  fileSystems."/tank/backups" = { 
    device = "tank/backups";
    fsType = "zfs";
  };
  fileSystems."/tank/backups/tim" = { 
    device = "tank/backups/tim";
    fsType = "zfs";
  };
  fileSystems."/tank/backups/karen" = { 
    device = "tank/backups/karen";
    fsType = "zfs";
  };
  fileSystems."/tank/music" = { 
    device = "tank/music";
    fsType = "zfs";
  };
  fileSystems."/tank/photos" = { 
    device = "tank/photos";
    fsType = "zfs";
  };
  fileSystems."/tank/videos" = { 
    device = "tank/videos";
    fsType = "zfs";
  };

  # for sharing out read-only backup snapshots
  fileSystems."/tank/music/tim" = { 
    device = "/tank/backups/tim/.zfs/snapshot/latest/timwi/Music";
    options = ["bind"];
  };
  fileSystems."/tank/music/karen" = { 
    device = "/tank/backups/karen/.zfs/snapshot/latest2/karencornish/Music";
    options = ["bind"];
  };
  fileSystems."/tank/photos/tim" = { 
    device = "/tank/backups/tim/.zfs/snapshot/latest/timwi/Pictures/Exports";
    options = ["bind"];
  };
  fileSystems."/tank/photos/karen" = { 
    device = "/tank/backups/karen/.zfs/snapshot/latest2/karencornish/Pictures";
    options = ["bind"];
  };


  # Network
  networking = {
    hostName = "evil";  # Define your hostname.
    hostId = "4e999999";
    # enableIPv6 = false;
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 80 443 139 445 9000 9090 3483 32400];
      allowedUDPPorts = [ 137 138 3483 ];
    };
    # connman.enable = true;
  };

  powerManagement.enable = true;

  # security.grsecurity.enable = true;
  security.sudo.enable = true;

  services = {
    acpid.enable = true;
    thinkfan.enable = true; # cannot use thermald on this old machine
    tlp.enable = true;
    locate.enable = true;

    # By default, the auto-snapshot service will keep the latest four
    # 15-minute, 24 hourly, 7 daily, 4 weekly and 12 monthly snapshots.
    zfs.autoSnapshot.enable = true;

    samba = {
            enable = true;
            shares = {
              Music =
                { path = "/tank/music";
                  "read only" = "yes";
                  public = "yes";
                  browseable = "yes";
                  "guest ok" = "yes";
                  "follow symlinks" = "yes";
                  "wide links" = "yes";
                };
            };
            extraConfig = ''
            workgroup = WORKGROUP
            netbios name = evil
            socket options = TCP_NODELAY SO_RCVBUF=8192 SO_SNDBUF=8192
            hosts allow = 192.168.1.
            load printers = no
            guest account = smbguest
            map to guest = bad user

            # stop sonos trying to follow symlinks locally
            # as unlike Windows, it understands unix extensions
            unix extensions = no

            # log level = 2
            '';
          };

    # check this
    openssh = {
      enable = true;
      passwordAuthentication = true;
    };
  };

  # Additional users
  # Note: Tim is defined in common.nix
  users.extraUsers.karen = {
    description = "Karen Williams";
    isNormalUser = true;
    uid = 1001;
  };

  # create the smbguest user, otherwise connections will fail
  users.users.smbguest =
      { name = "smbguest";
        uid  = config.ids.uids.smbguest;
        description = "smb guest user";
      };

  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
  '';

  services.udev.extraRules = ''
  # spindown /dev/sdb and /dev/sdc after 15 minutes of inactivity
  ACTION=="add", SUBSYSTEM=="block", KERNEL=="sdb", RUN+="${pkgs.hdparm}/bin/hdparm -S 180 /dev/sdb"
  ACTION=="add", SUBSYSTEM=="block", KERNEL=="sdc", RUN+="${pkgs.hdparm}/bin/hdparm -S 180 /dev/sdc"
'';

  virtualisation.docker.enable = true;

  # systemd.services.zfs-mount.wantedBy = ["local-fs.target"];
  # systemd.services.zfs-mount.requires = ["zfs-import.target"];
  # systemd.services.samba-smbd.after = [ "zfs-mount.service" ];

  systemd.services.squeezebox = {
      description = "Logitech Squeezebox Server";
      after = [ "network.target" "docker.socket" ];
      requires = [ "docker.socket" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = ''${pkgs.docker}/bin/docker run -d \
           -p 9000:9000 \
           -p 3483:3483 \
           -p 3483:3483/udp \
           -v /etc/localtime:/etc/localtime:ro \
           -v /tmp/squeezebox:/srv/squeezebox \
           -v /tank/music:/srv/music \
           larsks/logitech-media-server
      '';
    };

  systemd.services.plexmediaserver = {
      description = "Plex Media Server";
      after = [ "network.target" "docker.socket" ];
      requires = [ "docker.socket" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = ''${pkgs.docker}/bin/docker run -d \
          --net=host \
          -e TZ="Europe/London" \
          -v /tmp/plex/database:/config \
          -v /tmp/plex/transcode:/transcode \
          -v /tank/photos:/data \
          plexinc/pms-docker
      '';
    };
}
