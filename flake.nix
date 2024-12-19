{
  description = "Dotnet website for rplwork.com. Showcase for Ryan Lynch's work.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0_1xx;
        dotnet-runtime = pkgs.dotnetCorePackages.aspnetcore_8_0;
        version = "0.0.1";
          projectFile = "rplwork.csproj";
                src = ./src;
      in rec {
        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
        };

        packages.rplwork = pkgs.buildDotnetModule {
                    inherit src projectFile dotnet-sdk dotnet-runtime version;
          pname = "rplwork_client";
          nugetDeps = ./deps.nix; #`nix build .#default.passthru.fetch-deps && ./result` and put the result here
          doCheck = true;
        };

        packages.default = self.packages.${system}.rplwork;

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
