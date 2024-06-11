/** Adds a custom menu item to the LibreNMS web interface. */
final: prev:
let
  local = ./.;
in
{
  librenms = prev.librenms.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      install -d $out/resources/views/menu
      install -m 444 ${local}/custom.blade.php $out/resources/views/menu/
    '';
  });
}
