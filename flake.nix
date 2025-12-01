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
      version = builtins.substring 0 8 lastModifiedDate;

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
      packages = forAllSystems (
        system: {
          rplwork-client = import ./default.nix {
            inherit system inputs;
            nixpkgs = nixpkgsFor.${system};
          };
          default = self.packages.${system}.rplwork-client;
          rplwork-image = import ./pkgs/rplwork-client-image.nix {
            nixpkgs = nixpkgsFor.${system};
            rplwork-client = self.packages.${system}.default;
          };
        }
      );

      devShells = forAllSystems (system: {
        default = import ./shell.nix {
          inherit system inputs;
          nixpkgs = nixpkgsFor.${system};
        };
      });
    } // {
      # nixosModules.default = nixCats.nixosModules.default;
    };
}
