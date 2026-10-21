# SocketCAN. A virtual bus for development and simulation, and the real
# interface on the car (500 kbit/s, from can_node/setup.sh).
{ config, lib, pkgs, ... }:
let
  cfg = config.ads.can;
  ip = "${pkgs.iproute2}/bin/ip";
in
{
  options.ads.can = {
    enable = lib.mkEnableOption "SocketCAN support";

    virtual = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Create a virtual CAN bus for development and simulation.";
      };
      interface = lib.mkOption { type = lib.types.str; default = "vcan0"; };
    };

    hardware = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Bring up a physical CAN interface when it appears.";
      };
      interface = lib.mkOption { type = lib.types.str; default = "can0"; };
      bitrate = lib.mkOption { type = lib.types.ints.positive; default = 500000; };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "can" "can_raw" ] ++ lib.optional cfg.virtual.enable "vcan";
    environment.systemPackages = [ pkgs.can-utils ];

    systemd.services = lib.mkMerge [
      (lib.mkIf cfg.virtual.enable {
        "can-${cfg.virtual.interface}" = {
          description = "Virtual CAN bus ${cfg.virtual.interface}";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
          script = ''
            ${ip} link show ${cfg.virtual.interface} >/dev/null 2>&1 \
              || ${ip} link add dev ${cfg.virtual.interface} type vcan
            ${ip} link set up ${cfg.virtual.interface}
          '';
        };
      })
      (lib.mkIf cfg.hardware.enable {
        "can-${cfg.hardware.interface}" =
          let dev = "sys-subsystem-net-devices-${cfg.hardware.interface}.device";
          in {
            description = "CAN bus ${cfg.hardware.interface} at ${toString cfg.hardware.bitrate} bit/s";
            wantedBy = [ "multi-user.target" dev ];
            bindsTo = [ dev ];
            after = [ dev ];
            serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
            script = ''
              ${ip} link set ${cfg.hardware.interface} down || true
              ${ip} link set ${cfg.hardware.interface} type can bitrate ${toString cfg.hardware.bitrate}
              ${ip} link set up ${cfg.hardware.interface}
            '';
          };
      })
    ];
  };
}
