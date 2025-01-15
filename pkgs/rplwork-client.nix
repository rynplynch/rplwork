{
  dotnetCorePackages,
  buildDotnetModule,
  system,
  inputs,
}: let
  # started configuration attributes for dotnet projects
  pname = "rplwork_client";
  version = "1.0.2";
  projectFile = "rplwork_client.csproj";
  src = ../rplwork_client;
  port = "5000";

  # controls what sdk the project is built with and what runtime it is run in
  dotnet-sdk = dotnetCorePackages.sdk_8_0_1xx;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

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
