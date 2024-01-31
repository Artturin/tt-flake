# Tenstorrent Software (unofficial, WIP)

## Installing kmod

Add this flake to your configuration flake's inputs and pin its `nixpkgs` to your version.

```
tt-flake = {
  url = "git+https://git.ziguana.dev/ziguana/tt-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```


Enable hugepages and IOMMU passthrough. One 1G page is needed per Grayskull, and two for each Wormhole. Add the kernel module to your configuration.

`flake.nix`:

```
hostname = nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ...
    (import ./machines/hostname/configuration.nix)
    # perhaps this module could be shipped by the flake in the future
    ({ pkgs, ... }: {
      boot.extraModulePackages = [ tt-flake.packages.x86_64-linux.kmd ];
      boot.kernelParams = [ "hugepagesz=1G" "hugepages=2" "iommu=pt" ];
      boot.kernelModules = [ "tenstorrent" ];
      services.udev.packages = [ tt-flake.packages.x86_64-linux.udev-rules ];
    })
    ...
```

Reboot and run the tests. Some of the tests may require root.

```
nix run git+https://git.ziguana.dev/ziguana/tt-flake#kmd-test 
```

You should see testing output on stdout, and some errors (with a possible stack trace) in dmesg.

`stdout`:

```
Testing /dev/tenstorrent/0 @ 0000:a8:00.0
Testing /dev/tenstorrent/1 @ 0000:76:00.0
```

`dmesg`:

```
[  173.045092] tenstorrent: pin_user_pages_longterm failed: -14
[  173.046086] tenstorrent: could only pin 1 of 2 pages
```

As far as I can tell, these failures are exercised by the tests, and a clean `stdout` means there is no issue.
