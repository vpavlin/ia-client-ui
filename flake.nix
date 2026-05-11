{
  description = "IA Client UI Module";

  inputs = {
    logos-module-builder.url = "/home/vpavlin/devel/logos-module-builder-patched";
  };

  outputs = inputs@{ logos-module-builder, ... }:
    logos-module-builder.lib.mkLogosQmlModule {
      src = ./.;
      configFile = ./metadata.json;
      flakeInputs = inputs;
    };
}
