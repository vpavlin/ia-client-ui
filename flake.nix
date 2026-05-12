{
  description = "IA Client UI Module";

  inputs = {
    logos-module-builder.url = "/home/vpavlin/devel/logos-module-builder-patched";
    logos-ia.url = "/home/vpavlin/devel/logos-ia";
  };

  outputs = inputs@{ logos-module-builder, logos-ia, ... }:
    let
      # Get the include directory from logos-ia's output
      logosIaIncludeDir = "${logos-ia.packages.x86_64-linux.default}/include";
      
      # Get nixpkgs.lib for common.nix (needs zipAttrsWith etc.)
      mbLib = inputs.logos-module-builder.lib;
      mbNixpkgs = inputs.logos-module-builder.inputs.nixpkgs;
      
      # Bind builderRoot explicitly by importing mkLogosModule.nix directly
      # This avoids the nested flake context issue where builderRoot isn't passed
      mkLogosModuleDirect = import (inputs.logos-module-builder + "/lib/mkLogosModule.nix") {
        nixpkgs = mbNixpkgs;
        logos-cpp-sdk = inputs.logos-module-builder.inputs.logos-cpp-sdk;
        logos-module = inputs.logos-module-builder.inputs.logos-module;
        nix-bundle-lgx = inputs.logos-module-builder.inputs.nix-bundle-lgx;
        logos-standalone-app = inputs.logos-module-builder.inputs.logos-standalone-app;
        lib = mbNixpkgs.lib;
        common = import (inputs.logos-module-builder + "/lib/common.nix") { lib = mbNixpkgs.lib; };
        parseMetadata = import (inputs.logos-module-builder + "/lib/parseMetadata.nix") { lib = mbNixpkgs.lib; };
        builderRoot = inputs.logos-module-builder;
      };
      
      # Build with C++ compilation via mkLogosModule
      iaUiModule = mkLogosModuleDirect {
        src = ./.;
        configFile = ./metadata.json;
        flakeInputs = inputs;
        extraNativeBuildInputs = [ logos-ia.packages.x86_64-linux.default ];
        preConfigure = ''
          export LOGOS_IA_INCLUDE_DIR="${logosIaIncludeDir}"
        '';
      };
    in
      iaUiModule;
}
