{ check-brandmeister-flake }:
/** Adds the check-brandmeister package from the flake */
final: prev: {
  check-brandmeister = check-brandmeister-flake.packages.x86_64-linux.default;
}
