final: prev: {
  librenms = prev.librenms.overrideAttrs (oldAttrs: rec {
    pname = "librenms";
    version = "24.6.0";
    src = prev.fetchFromGitHub {
      owner = "librenms";
      repo = pname;
      rev = "${version}";
      sha256 = "sha256-FCMN9Z3mz1wr/MxSYKojIAxggxOe5JmftEmT6B+v3ds=";
    };
    vendorHash = "sha256-pRPYJs299I8eGIQH5PNk6yqXf6P6EEOFym91UEEFa4Q=";
  });
}
