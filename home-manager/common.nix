{ pkgs, username, homeDirectory, ... }:

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
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    cargo
    nil
    nixfmt
    rust-analyzer
    openssh
    ouch
    gh
    fd
    ltex-ls
    zola
    http-prompt
    sqlx-cli
    sqlite
    taplo

    nodePackages.vscode-css-languageserver-bin
    nodePackages.typescript-language-server
    nodePackages.prettier

    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    (python3.withPackages
      (pyPkgs: with pyPkgs; [ python-lsp-server python-lsp-ruff ]))

  ];

  fonts.fontconfig.enable = true;

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
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  home.shellAliases = {
    htop = "btm";
    top = "btm";
    ls = "eza";
    cat = "bat";
    tree = "ls -T";
    ga = "git add -A";
    gc = "git commit";
    gp = "git push";
    gco = "git checkout";
    gs = "git status"; # conflicts with ghostscript `gs`
    cd = "z";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      bindkey '^[[Z' autosuggest-accept
    '';
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    languages = {
      language-server = {
        rust-analyzer = {
          config.check.command = "clippy";
          imports.granularity.group = "crate";
        };
        css = {
          command = "css-languageserver";
          args = [ "--stdio" ];
        };
        latex-lsp.command = "ltex-ls";
        typescript-language-server.config.documentFormatting = false;
        eslint = {
          command = "vscode-eslint-language-server";
          args = [ "--stdio" ];
          config = {
            validate = "on";
            experimental = { useFlatConfig = false; };
            rulesCustomizations = [ ];
            run = "onType";
            problems = { shortenToSingleLine = false; };
            nodePath = "";
            codeAction = {
              disableRuleComment = {
                enable = true;
                location = "separateLine";
              };
              showDocumentation.enable = true;
            };
            codeActionOnSave = {
              enable = true;
              mode = "fixAll";
            };
            workingDirectory.mode = "location";
          };
        };
      };

      language = [
        {
          name = "nix";
          formatter = { command = "nixfmt"; };
          auto-format = true;
        }

        {
          name = "markdown";
          language-servers = [ "latex-lsp" ];
          file-types = [ "md" "txt" ];
          scope = "text.markdown";
          roots = [ ];
        }

        {
          name = "css";
          language-servers = [ "css" ];
        }

        {
          name = "scss";
          language-servers = [ "css" ];
        }

        {
          name = "typescript";
          auto-format = true;
          language-servers = [
            {
              except-features = [ "format" ];
              name = "typescript-language-server";
            }
            "eslint"
          ];
          formatter = {
            command = "prettier";
            args = [ "--parser" "typescript" ];
          };
        }
      ];

    };
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        soft-wrap.enable = true;
        bufferline = "multiple";
        color-modes = true;
        lsp = {
          display-inlay-hints = true;
          display-messages = true;
        };
      };
    };
  };

  programs.starship = let flavour = "mocha";
  in {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$all";
      palette = "catppuccin_${flavour}";
    } // builtins.fromTOML (builtins.readFile (pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "starship";
      rev = "5629d23";
      sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
    } + /palettes/${flavour}.toml));
  };

  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    stdlib = ''
      : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
        local hash path
        echo "''${direnv_layout_dirs[$PWD]:=$(
          hash="$(shasum - <<< "$PWD" | head -c40)"
          path="''${PWD//[^az-AZ-09]/-}"
          echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
        )}"
      }
    '';
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
      gpg.ssh.allowedSignersFile = "${homeDirectory}/.ssh/allowed_signers";
      core.editor = "hx";
      push.autoSetupRemote = true;
    };
  };

  programs.ssh = {
    enable = true;
    compression = true;
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      ui.pane_frames.hide_session_name = true;
    };
  };

  programs.bottom.enable = true;

  programs.eza = {
    enable = true;
    git = true;
    icons = true;
  };

  programs.bat.enable = true;

  programs.ripgrep.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
