{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; let
            latex = texlive.combine {
              inherit (texlive) scheme-basic latexmk
                babel-swedish hyphen-swedish biblatex biber
                collection-fontsrecommended microtype crimson xkeyval fontaxes
                siunitx
                booktabs
              ;
            };
          in [
            latex
          ];
        };
      });
}
