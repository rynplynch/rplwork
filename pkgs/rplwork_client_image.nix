{
  rplwork_client,
  dockerTools,
  lib,
  fakeNss,
}: let
  image = dockerTools.buildLayeredImage {
    name = lib.strings.concatStrings [rplwork_client.pname "_" rplwork_client.version];

    tag = "latest";
    contents = [
      fakeNss
    ];
    #"${rplwork_client.port}/tcp" = { };
    config = {
      Cmd = ["${rplwork_client}/bin/${rplwork_client.pname}"];
      extraCommands = ''
        mkdir -p /tmp/
      '';
      #ExposedPorts = {
      #        "5001" = { };
      #};
    };
  };
in
  image
