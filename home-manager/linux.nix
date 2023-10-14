{ config, pkgs, ... }: import ./common.nix {
  inherit config pkgs;
  username = "asm";
  homeDirectory = "/home/asm";
}