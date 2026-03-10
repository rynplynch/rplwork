{ system
, inputs
, dotnet-sdk
, mkShell
}:
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
    dotnet-sdk
  ];

  shellHook = ''
    # append global dotnet tools to PATH
    export PATH="$PATH:$HOME/.dotnet/tools"
    # global tools use this environment variable to locate dotnet runtime
    export DOTNET_ROOT=${dotnet-sdk}/share/dotnet/
  '';
}

