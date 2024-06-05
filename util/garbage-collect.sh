nix-env --delete-generations old
nix-store --gc
sudo nix-collect-garbage -d