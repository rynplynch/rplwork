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
        # assign the default package to run with 'nix run .'
        apps.default = {
          type = "app";
          # self' = self prime
          # self' allows us to reference the future derivation that is created with this flake
          program = self'.packages.rplwork-client;
        };

        # assign default package to build with 'nix build .'
        packages.default = self'.packages.rplwork-client;

        # call the rplwork-client nix module and expose it via the packages.rplwork attribute
        # this is what is referenced with self'.packages.rplwork-client
        packages.rplwork-client = pkgs.callPackage ./pkgs/rplwork-client.nix {inherit inputs;};

        # use 'nix fmt' before committing changes in git
        formatter = pkgs.alejandra;

        # development environment used to work on dotnet source code
        # enter using 'nix develop'
        devShells.default = pkgs.mkShell {
          shellHook = ''
            # append global dotnet tools to PATH
            export PATH="$PATH:$HOME/.dotnet/tools"

            # global tools use this environment variable to locate dotnet runtime
            export DOTNET_ROOT=${pkgs.dotnetCorePackages.sdk_8_0_1xx}/share/dotnet/
          '';

          buildInputs = [
            (
              with pkgs.dotnetCorePackages;
                combinePackages [
                  pkgs.dotnetCorePackages.dotnet_9.sdk
                  pkgs.dotnetCorePackages.dotnet_9.aspnetcore
                ]
            )
          ];
        };

        # builds a docker image of rplwork-client!
        # use 'docker load < result' to give docker access to the image
        packages.image = pkgs.callPackage ./pkgs/rplwork-client-image.nix {
          rplwork-client = self'.packages.rplwork-client;
        };
      };
    };
}
