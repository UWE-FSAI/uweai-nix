# NVIDIA driver and CUDA. Packages are not rebuilt with CUDA support by
# default (cudaSupport), because that turns cached downloads into hours of
# compiling; projects that need CUDA-enabled builds get them in a dev shell.
{ config, lib, pkgs, ... }:
let
  cfg = config.ads.cuda;
in
{
  options.ads.cuda = {
    enable = lib.mkEnableOption "the NVIDIA driver and CUDA toolkit";

    openKernelModule = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "NVIDIA's open kernel module. Needs a Turing (RTX 20xx / GTX 16xx) or newer GPU; set false for older cards.";
    };

    toolkit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the CUDA toolkit (nvcc and libraries) system-wide.";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = lib.mkDefault true;
    hardware.graphics.enable = lib.mkDefault true;
    services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
    hardware.nvidia = {
      open = lib.mkDefault cfg.openKernelModule;
      modesetting.enable = lib.mkDefault true;
      package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
    };
    hardware.nvidia-container-toolkit.enable = lib.mkDefault false;
    environment.systemPackages = lib.optionals cfg.toolkit [ pkgs.cudaPackages.cudatoolkit pkgs.nvtopPackages.nvidia ];
  };
}
