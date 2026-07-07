{ ... }:
{
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      # Do not inherit upstreams from resolvconf. Combined with
      # tailscale accept-dns=false (see tailscale.nix), this prevents the
      # DNS forwarding loop where hamnet.radio queries were routed to
      # Tailscale MagicDNS (100.100.100.100), which had no resolver for them
      # and fell back to the system default resolver (dnsmasq) -> loop
      # ("Maximum number of concurrent DNS queries reached (max: 150)").
      no-resolv = true;
      server = [
        # hamnet.radio: use the authoritative AMPRNet resolvers ONLY, so
        # queries never fall back to the public resolver below (avoids any
        # split-horizon mismatch for internal-only hamnet names).
        "/hamnet.radio/44.9.16.66"
        "/hamnet.radio/44.9.16.35"
        # General + global upstreams. The AMPRNet resolvers are recursive and
        # resolve global names too; 45.11.45.11 (DNS.SB, public) is kept as a
        # redundant fallback for global resolution.
        "44.9.16.66"
        "44.9.16.35"
        "45.11.45.11"
        # tailnet peer names still resolve via Tailscale MagicDNS, which keeps
        # answering on 100.100.100.100 even with accept-dns=false.
        "/ts.net/100.100.100.100"
      ];
    };
  };

}
