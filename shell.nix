{ nixpkgs ? import <nixpkgs> { }
, system
, inputs
,
}:
with nixpkgs;
let
  ryanl-nvim = inputs.ryanl-nvim.packages.${system}.default;
  inherit (ryanl-nvim) utils;
  customNixCats = (
    ryanl-nvim.override (prev: {
      name = "ryanl-nvim";

      packageDefinitions = prev.packageDefinitions // {
        # the name here is what will show up in CLI
        ryanl-nvim = utils.mergeCatDefs prev.packageDefinitions.nvim (
          { pkgs, ... }:
          {
            categories = {
              lua = true;
              nix = true;
              ui = true;
              csharp = true;
            };
          }
        );
      };
    })
  );
in
mkShell {
  buildInputs = [
    customNixCats
  ];

  shellHook = ''
    # append global dotnet tools to PATH
    export PATH="$PATH:$HOME/.dotnet/tools"
    # global tools use this environment variable to locate dotnet runtime
    export DOTNET_ROOT=${pkgs.dotnetCorePackages.sdk_8_0_1xx}/share/dotnet/
  '';
}

