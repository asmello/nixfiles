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

  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "~/.config/alacritty/catppuccin-mocha.toml" ];
      font = {
        normal.family = "FiraCode Nerd Font";
        size = 14.0;
      };
      window.option_as_alt = "OnlyLeft";
    };
  };
}
