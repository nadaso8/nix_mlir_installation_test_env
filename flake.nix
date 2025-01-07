{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs"; # avoids duplicating nixpkgs
    };
  };

  outputs = { self, nixpkgs, fenix, flake-utils }:
      let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        rustToolchain = fenix.packages.${system}.fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = "sha256-s1RPtyvDGJaX/BisLT+ifVfuhDT1nZkZ1NcK8sbwELM=";
        };
        
	rustPlatform = pkgs.makeRustPlatform {
          # inherit (rustToolchain) cargo rustc;
          cargo = rustToolchain.cargo;
          rustc = rustToolchain.rustc;
        };

      in
      {
	devShells.${system}.default = pkgs.mkShell {

          buildInputs = (with pkgs; [
            xorg.libxcb
            libxml2
	    llvmPackages_19.mlir
          ]);
	
	  nativeBuildInputs = [
            rustToolchain
            rustPlatform.bindgenHook
	    pkgs.llvmPackages_19.libllvm
          ];        
        };

        formatter.${system} = pkgs.nixpkgs-fmt;
      };
}
