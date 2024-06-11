final: prev: {
  /** Add the check_brandmeister binary to the monitoring-plugins */
  monitoring-plugins = prev.monitoring-plugins.overrideAttrs (oldAttrs: {
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ prev.check-brandmeister ];
    postInstall = (oldAttrs.postInstall or "") + ''
      install -d $out/bin
      install -m 755 ${prev.check-brandmeister}/bin/check_brandmeister $out/bin/
    '';
  });
}
