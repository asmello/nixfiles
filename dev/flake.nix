{
  description = "Default Dev Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
      in with pkgs; {
        devShells.default = mkShell {
          packages = with pkgs; [
            # Nix
            nil
            nixfmt

            # Rust
            (rust-bin.stable.latest.default.override {
              extensions = [ "rust-src" ];
            })
            rust-analyzer

            # TOML
            taplo

            # Python
            (python3.withPackages
              (pyPkgs: with pyPkgs; [ python-lsp-server python-lsp-ruff ]))

            # Typescript / Frontend
            nodePackages.vscode-css-languageserver-bin
            nodePackages.typescript-language-server
            nodePackages.prettier
            nodePackages.svelte-language-server

          ];
        };
      });
}