{
  description = "Dotnet website for rplwork.com. Showcase for Ryan Lynch's work.";

  inputs = {
    # helpful tools for maintaining the flake
    flake-parts.url = "github:hercules-ci/flake-parts";

    # use nix flake update to bump the version of nixpkgs used
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # helpful tool to manage dotnet nuget dependencies
    nuget-packageslock2nix = {
      url = "github:mdarocha/nuget-packageslock2nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
  # generate the flake, while passing input attributes
    flake-parts.lib.mkFlake {inherit inputs;} {
      # different systems that rplwork can be built for
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      # helper function that handles ${system} for us
      perSystem = {
        # used to reference nixpkgs, called because we inherited inputs
        pkgs,
        self',
        ...
      }: {
        };

        packages.default = packages.rplwork;

        packages.image = pkgs.dockerTools.buildImage {
          name = nixpkgs.lib.strings.concatStrings [pname "_image"];
        # call the rplwork_client nix module and expose it via the packages.rplwork attribute
        # this is what is referenced with self'.packages.rplwork_client
        packages.rplwork_client = pkgs.callPackage ./pkgs/rplwork_client.nix {inherit inputs;};

          config = {
            Cmd = ["${pkgs.hello}/bin/hello"];
          };
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            (with pkgs.dotnetCorePackages;
              combinePackages [
                dotnet-sdk
                dotnet-runtime
              ])
          ];
        };
      }
    );
    };
}
