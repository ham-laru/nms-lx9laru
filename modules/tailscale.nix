# Tailscale VPN – enabled on all NixOS hosts
# Includes shell completions for bash, zsh, and fish.
{...}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
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
