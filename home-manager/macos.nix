{ lib, config, pkgs, ... }:
let
  rendered = import ./common.nix {
    inherit config pkgs;
    username = "asm";
    homeDirectory = "/Users/asm";
  };
in lib.attrsets.recursiveUpdate rendered {
  programs.zsh.initExtra = lib.mkOrder 150 (''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
  '' + rendered.programs.zsh.initExtra);
}
