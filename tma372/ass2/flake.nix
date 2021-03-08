{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (let packages = python-packages: with python-packages; [
                   numpy scipy matplotlib
                 ];
                 in python3.withPackages packages)

            (texlive.combine {
              inherit (texlive) scheme-basic latexmk
                pgf xcolor caption subfigure microtype listings;
            })
          ];
        };
      });
}
