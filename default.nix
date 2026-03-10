{ system
, inputs
, buildDotnetModule
, dotnet-sdk
, dotnet-runtime
, version
, port
}:
let
  # started configuration attributes for dotnet projects
  pname = "rplwork_client";
  projectFile = "rplwork_client.csproj";
  src = ./rplwork_client;

  # helpful tool that will handle nuget dependencies
  nuget-packageslock2nix = inputs.nuget-packageslock2nix;

  # create derivation that represents the packaged web application
  rplwork = buildDotnetModule {
    inherit pname src projectFile dotnet-sdk dotnet-runtime version port;

    nugetDeps = nuget-packageslock2nix.lib {
      inherit system;
      name = pname;
      lockfiles = [
        (src + "/packages.lock.json")
      ];
    };

    # not sure what this does
    doCheck = true;

    # tell the flake the name of the executable so it can find it
    meta.mainProgram = pname;

    # environment variables set at runtime
    makeWrapperArgs = [
      "--set DOTNET_CONTENTROOT ${placeholder "out"}/lib/${pname}"
      "--set ASPNETCORE_URLS http://+:${port}/"
    ];
  };
in
rplwork
