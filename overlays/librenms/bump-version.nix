final: prev: {
  librenms = prev.librenms.overrideAttrs (oldAttrs: rec {
    pname = "librenms";
    version = "24.5.0";
    src = prev.fetchFromGitHub {
      owner = "librenms";
      repo = pname;
      rev = "${version}";
      sha256 = "sha256-Qr5SiNcBS5sTnV0lv8PYG5eXZxWfEfbuMZ70P+LPqNY=";
    };
    vendorHash = "sha256-mrwewYRfVnkeC5onPvZRNtnt7VGm/JuS871W9kct7to=";
  });
}
