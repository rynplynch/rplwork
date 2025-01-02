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

        pname = "rplwork_client";
        version = "0.0.1";
        projectFile = "rplwork_client.csproj";
        src = ./src;

        dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0_1xx;
        dotnet-runtime = pkgs.dotnetCorePackages.aspnetcore_8_0;
      # helper function that handles ${system} for us
      perSystem = {
        # used to reference nixpkgs, called because we inherited inputs
        pkgs,
        self',
        ...
      }: {
        };

        packages.default = packages.rplwork;

        packages.rplwork = pkgs.buildDotnetModule {
          inherit pname src projectFile dotnet-sdk dotnet-runtime version;
          nugetDeps = nuget-packageslock2nix.lib {
            inherit system;
            name = pname;
            lockfiles = [
              ./src/packages.lock.json
            ];
          };
          doCheck = true;
        };

        packages.image = pkgs.dockerTools.buildImage {
          name = nixpkgs.lib.strings.concatStrings [pname "_image"];

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
