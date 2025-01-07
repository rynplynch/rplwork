{
  rplwork_client,
  dockerTools,
  lib,
  buildEnv,
  runtimeShell,
}: let
  image = dockerTools.buildImage {
    name = lib.strings.concatStrings [rplwork_client.pname "_" rplwork_client.version];
    tag = "latest";
    copyToRoot = buildEnv {
      name = "image-root";
      paths = [rplwork_client];
      pathsToLink = ["/bin"];
    };
    runAsRoot = ''
      #!${runtimeShell}
      mkdir -p /tmp
    '';

    config = {
      Cmd = ["/bin/rplwork_client"];

      ExposedPorts = {
        "5000" = {};
      };
    };
  };
in
  image
