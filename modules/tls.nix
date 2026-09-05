{ config
, pkgs
, ...
}:
let
  fqdn = config.services.librenms.hostname;
  certDir = "/var/lib/nginx-selfsigned";
in
{
  # ACME is not usable on this host: its egress is NATed to senn's WAN address,
  # so Let's Encrypt cannot reach it on port 80 for HTTP-01, and the
  # hamnet.radio zone is delegated elsewhere so DNS-01 is not available either.
  # Generate a long-lived self-signed certificate instead. Browsers will warn
  # once per client; accepting it stores a permanent exception.
  systemd.services.nginx-selfsigned-cert = {
    description = "Self-signed TLS certificate for ${fqdn}";
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];
    requiredBy = [ "nginx.service" ];
    path = [ pkgs.openssl ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p ${certDir}
      # Regenerate only when missing or within 30 days of expiry.
      if ! openssl x509 -checkend $(( 30 * 24 * 3600 )) -noout \
             -in ${certDir}/cert.pem >/dev/null 2>&1; then
        openssl req -x509 -newkey rsa:2048 -nodes -sha256 -days 3650 \
          -keyout ${certDir}/key.pem -out ${certDir}/cert.pem \
          -subj "/CN=${fqdn}" \
          -addext "subjectAltName=DNS:${fqdn},DNS:nms.lx2sg.hamnet.radio,DNS:nms,IP:44.161.251.2" \
          -addext "basicConstraints=critical,CA:FALSE" \
          -addext "keyUsage=critical,digitalSignature,keyEncipherment" \
          -addext "extendedKeyUsage=serverAuth"
      fi
      chown root:${config.services.nginx.group} ${certDir}/cert.pem ${certDir}/key.pem
      chmod 0644 ${certDir}/cert.pem
      chmod 0640 ${certDir}/key.pem
    '';
  };

  # addSSL, not forceSSL: port 80 keeps serving unchanged, so the LibreNMS API
  # (used by the ansible dynamic inventory over http) and existing http://
  # bookmarks are unaffected.
  services.librenms.nginx = {
    addSSL = true;
    sslCertificate = "${certDir}/cert.pem";
    sslCertificateKey = "${certDir}/key.pem";
  };
}
