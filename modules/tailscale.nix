# Tailscale VPN – enabled on all NixOS hosts
# Includes shell completions for bash, zsh, and fish.
{...}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    # Do not let Tailscale take over DNS on this host. It was registering as the
    # exclusive resolvconf provider, which caused openresolv to route the
    # hamnet.radio search domain to MagicDNS (100.100.100.100) instead of the
    # real AMPRNet resolvers, producing a dnsmasq<->MagicDNS forwarding loop.
    # MagicDNS still answers on 100.100.100.100, so *.ts.net names are resolved
    # via an explicit dnsmasq route (see dnsmasq.nix).
    extraSetFlags = [ "--accept-dns=false" ];
  };

  # Shell completions for tailscale
  programs.bash.interactiveShellInit = ''
    if command -v tailscale &>/dev/null; then
      source <(tailscale completion bash)
    fi
  '';

  programs.zsh.interactiveShellInit = ''
    if command -v tailscale &>/dev/null; then
      source <(tailscale completion zsh)
    fi
  '';

  programs.fish.shellInit = ''
    if command -v tailscale &>/dev/null
      tailscale completion fish | source
    end
  '';
}
