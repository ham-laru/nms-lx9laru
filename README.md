# LibreNMS on NixOS

This is a configuration for running [LibreNMS](https://www.librenms.org/) on [NixOS](https://nixos.org/), with a few additions and fixes to make it run smoothly and easier to administer.

Some additions include:
- a service check for the online status of [BrandMeister]() radio repeaters using [check_brandmeister](https://github.com/sgrimee/check_brandmeister)
- an instance of oxidized to store backups of devices configs
