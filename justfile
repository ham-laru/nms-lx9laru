default:
    @just --list

switch:
    sudo nixos-rebuild switch --flake .

update:
    nix flake update
