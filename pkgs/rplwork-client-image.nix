{ rplwork-client
, nixpkgs
,
}: with nixpkgs; let
  image = dockerTools.buildImage {
    name = lib.strings.concatStrings [ "rynplynch/" rplwork-client.pname ];
    tag = rplwork-client.version;

    copyToRoot = buildEnv {
      name = "image-root";
      paths = [ rplwork-client ];
      pathsToLink = [ "/bin" ];
    };

    runAsRoot = ''
      #!${runtimeShell}
      mkdir -p /tmp
    '';

    config = {
      Cmd = [ rplwork-client.pname ];

      ExposedPorts = {
        "${rplwork-client.port}/tcp" = { };
      };
    };
  };
in
image
