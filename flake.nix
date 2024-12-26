{
  description = "Dotnet website for rplwork.com. Showcase for Ryan Lynch's work.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nuget-packageslock2nix = {
      url = "github:mdarocha/nuget-packageslock2nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nuget-packageslock2nix,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        pname = "rplwork_client";
        version = "0.0.1";
        projectFile = "rplwork_client.csproj";
        src = ./src;

        dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0_1xx;
        dotnet-runtime = pkgs.dotnetCorePackages.aspnetcore_8_0;
      in rec {
        apps.default = flake-utils.lib.mkApp {
          drv = packages.default;
        };

        packages.default = packages.rplwork;

        packages.rplwork = pkgs.buildDotnetModule {
          nugetDeps = ./deps.nix; #`nix build .#default.passthru.fetch-deps && ./result` and put the result here
          inherit pname src projectFile dotnet-sdk dotnet-runtime version;
          doCheck = true;
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
}
