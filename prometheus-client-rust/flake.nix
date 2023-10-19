{
  description = "MacOS devEnv for prometheus/client_rust";

  inputs = { nixpkgs.url = "nixpkgs/nixos-23.05"; };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = import inputs.nixpkgs { inherit system; };
      devPython = pkgs.python39.withPackages (pyPkgs: with pyPkgs; [
        prometheus_client
      ]);
    in
    {
      devShells.${system}.python39 = pkgs.mkShell {
        nativeBuildInputs =
          [
            pkgs.libiconv
            devPython
          ];
        PYTHONPATH = "${devPython}/lib/python3.9/site-packages";
      };
    };
}
