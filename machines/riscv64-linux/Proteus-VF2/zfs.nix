{
  config,
  lib,
  pkgs,
  ...
}: let
  zfsCompatibleKernelPackages =
    lib.attrsets.filterAttrs (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name)
        != null
        && (builtins.tryEval kernelPackages).success
        && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    )
    pkgs.linuxKernel.packages;
  latestKernelPackage = lib.lists.last (
    lib.lists.sort
    (a: b: (lib.strings.versionOlder a.kernel.version b.kernel.version))
    (builtins.attrValues zfsCompatibleKernelPackages)
  );
in {
  # Note this might jump back and forth as kernels are added or removed.
  boot.kernelPackages = latestKernelPackage;
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
}
