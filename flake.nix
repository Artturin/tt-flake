{
  description = "Tenstorrent software stack.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    kernel = pkgs.linux_latest;
    kmd = import ./pkgs/kmd { inherit pkgs kernel; };
    sfpi = import ./pkgs/sfpi { inherit pkgs; };
    luwen = import ./pkgs/luwen { inherit pkgs; };
    common = import ./pkgs/common { inherit pkgs; };
    flash = import ./pkgs/flash { inherit pkgs; pyluwen = luwen.pyluwen_0_1; };
    smi = import ./pkgs/smi { inherit pkgs; pyluwen = luwen.pyluwen; tools-common = common; };
    umd = import ./pkgs/umd { inherit pkgs; };
  in {
    packages.${system} = {
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
    };

    formatter.${system} = pkgs.nixfmt-rfc-style;

    defaultPackage.${system} = self.packages.${system}.smi;
  };
}
