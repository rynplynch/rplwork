{
  dotnetCorePackages,
  buildDotnetModule,
  system,
  inputs,
}: let
  pname = "rplwork_client";
  version = "1.0.0";
  projectFile = "rplwork_client.csproj";
  src = ../src;
  port = "5000";

  dotnet-sdk = dotnetCorePackages.sdk_8_0_1xx;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  nuget-packageslock2nix = inputs.nuget-packageslock2nix;
  rplwork = buildDotnetModule {
    inherit pname src projectFile dotnet-sdk dotnet-runtime version port;

    nugetDeps = nuget-packageslock2nix.lib {
      inherit system;
      name = pname;
      lockfiles = [
        ../src/packages.lock.json
      ];
    };
    doCheck = true;
    meta.mainProgram = pname;
    makeWrapperArgs = [
      "--set DOTNET_CONTENTROOT ${placeholder "out"}/lib/${pname}"
      #"--set ASPNETCORE_URLS http://localhost:${port}/"
    ];
  };
in
  rplwork
