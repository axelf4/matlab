{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (python3.withPackages (python-packages: with python-packages; [
              numpy pandas matplotlib numba
            ]))
          ];
        };
      });
}
