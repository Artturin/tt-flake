{
  description = "Tenstorrent software stack.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs:
    let
      inherit (inputs) self;
      inherit (inputs.nixpkgs) lib;
    in
    inputs.utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        kernel = pkgs.linux_latest;
        kmd = import ./pkgs/kmd { inherit pkgs kernel; };
        sfpi = import ./pkgs/sfpi { inherit pkgs; };
        luwen = import ./pkgs/luwen { inherit pkgs; };
        common = import ./pkgs/common { inherit pkgs; };
        flash = import ./pkgs/flash {
          inherit pkgs;
          pyluwen = luwen.pyluwen_0_1;
          tools-common = common;
        };
        smi = import ./pkgs/smi {
          inherit pkgs;
          pyluwen = luwen.pyluwen;
          tools-common = common;
        };
        umd = import ./pkgs/umd { inherit pkgs; };
      in
      {
        packages = {
          kmd = kmd.kmd;
          udev-rules = kmd.udev-rules;
          kmd-test = kmd.test;
          sfpi = sfpi.sfpi;
          tt-gcc = sfpi.tt-gcc;
          smi = smi;
          luwen = luwen.luwen;
          pyluwen = luwen.pyluwen;
          tools-common = common;
          flash = flash;
          umd = umd;
          default = self.packages.${system}.smi;
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
