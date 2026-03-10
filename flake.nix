{
  description = "Dotnet website for rplwork.com. Showcase for Ryan Lynch's work.";

  inputs = {
    # use nix flake update to bump the version of nixpkgs used
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # helpful tool to manage dotnet nuget dependencies
    nuget-packageslock2nix = {
      url = "github:mdarocha/nuget-packageslock2nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ryan's prefered editor config
    ryanl-nvim = {
      url = "github:rynplynch/my-nixCats";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , ...
    }@inputs:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      revision = builtins.substring 0 8 lastModifiedDate;
      version = builtins.concatStringsSep "." [ "1" "1" revision ];

      port = "5000";

      # define which sdk/runtime used by the application
      # each represents an attribute path in nixpkgs
      dotnet-sdk = [ "dotnetCorePackages" "dotnet_9" "sdk" ];
      dotnet-runtime = [ "dotnetCorePackages" "dotnet_9" "aspnetcore" ];

      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        }
      );

    in

    {
      # A Nixpkgs overlay.
      overlays.default = final: prev: { };

      # Provide some binary packages for selected system types.
      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      packages = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
          in
          {
            rplwork-client = import ./default.nix {
              inherit system inputs version port;
              inherit (pkgs) buildDotnetModule;
              # resolve the attribute path to the actual derivation
              dotnet-sdk = pkgs.lib.attrsets.getAttrFromPath dotnet-sdk pkgs;
              dotnet-runtime = pkgs.lib.attrsets.getAttrFromPath dotnet-runtime pkgs;
            };
            default = self.packages.${system}.rplwork-client;
            rplwork-image = import ./pkgs/rplwork-client-image.nix {
              nixpkgs = pkgs;
              rplwork-client = self.packages.${system}.default;
            };
          }
        );

      devShells = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
          in
          {
            default = import ./shell.nix
              {
                inherit system inputs;
                inherit (pkgs) mkShell;
                dotnet-sdk = pkgs.lib.attrsets.getAttrFromPath dotnet-sdk pkgs;
              };
          });
    } // {
      # nixosModules.default = nixCats.nixosModules.default;
    };
}
