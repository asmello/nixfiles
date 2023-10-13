{ config, pkgs, username, homeDirectory, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = { inherit username homeDirectory; };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    nil
    nixpkgs-fmt
    rust-analyzer
    openssh
    tree

    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/asm/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "hx";
  };

  home.shellAliases = {
    ls = "ls --color=auto";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "FiraCode Nerd Font";
        };
        size = 16.0;
      };
      window.option_as_alt = "OnlyLeft";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    languages = {
      language = [
        {
          name = "nix";
          formatter = {
            command = "nixpkgs-fmt";
          };
        }
      ];

      language-server.rust-analyzer.config.check = {
        command = "clippy";
      };
    };
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        bufferline = "multiple";
        color-modes = true;
        lsp.display-inlay-hints = true;
      };
    };
  };

  programs.starship =
    let
      flavour = "mocha";
    in
    {
      enable = true;
      enableZshIntegration = true;
      # settings = {
      #   format = "$all";
      #   palette = "catppuccin_${flavour}";
      # } // builtins.fromTOML (builtins.readFile
      #   (pkgs.fetchFromGitHub
      #     {
      #       owner = "catppuccin";
      #       repo = "starship";
      #       rev = "5629d23";
      #       sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
      #     } + /palettes/${flavour}.toml));
    };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [ sensible vim-tmux-navigator catppuccin ];
    sensibleOnTop = false;
    baseIndex = 1;
    clock24 = true;
    extraConfig = ''
      # fix colours
      set -sg terminal-overrides ",*:RGB"

      # Shift arrow to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # set vi-mode
      set-window-option -g mode-keys vi
      # keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind _ split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
    '';
  };

  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "André Sá de Mello";
    userEmail = "asmello@pm.me";
    signing = {
      key = "${homeDirectory}/.ssh/id_ed25519_sk.pub";
      signByDefault = true;
    };
    lfs.enable = true;
    extraConfig = {
      gpg.format = "ssh";
      ssh.allowedSignersFile = "${homeDirectory}/.ssh/allowed_signers";
      core.editor = "hx";
      push.autoSetupRemote = true;
    };
  };

  programs.ssh = {
    enable = true;
    compression = true;
  };
}
