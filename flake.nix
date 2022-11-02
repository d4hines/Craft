{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };
  outputs = { self, nixpkgs, flake-utils, nix-filter }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; }; in
    with pkgs;
    {
      packages = {
        craft = stdenv.mkDerivation {
          src = nix-filter.lib.filter {
            root = ./.;
            include = [
              "deps"
              "src"
              "shaders"
              "textures"
              "CMakeLists.txt"
            ];
          };
          name = "env";
          nativeBuildInputs = [ cmake ];
          buildInputs = [ glew glfw xorg.libX11 mesa curl.dev ] ++ (with xorg; [ libXrandr libXinerama libXcursor ]);
        };
      };
      defaultPackage = self.packages."${system}".craft;
      devShell = mkShell {
        inputsFrom = [ self.packages."${system}".craft ];
        packages = [
          python3
          termdbms
          netcat-gnu
        ] ++ (with python310Packages; [ requests ]);
      };
    }

  );
}
