{ lib, config, pkgs, ... }:
let
  rendered = import ./common.nix {
    inherit config pkgs;
    username = "asm";
    homeDirectory = "/Users/asm";
  };
in lib.attrsets.recursiveUpdate rendered {
  programs.zsh.initExtra = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
    source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
    bindkey '^[[Z' autosuggest-accept
  '';
}
