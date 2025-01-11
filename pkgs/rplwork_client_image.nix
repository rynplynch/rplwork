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
      Cmd = [rplwork_client.pname];

      ExposedPorts = {
        "${rplwork_client.port}/tcp" = {};
      };
    };
  };
in
  image
