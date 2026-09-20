{
  description = "renovate-config";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem =
        { pkgs, system, ... }:
        let
          pnpm = pkgs.runCommand "pnpm" { buildInputs = [ pkgs.corepack ]; } ''
            mkdir -p $out/bin
            corepack enable pnpm --install-directory=$out/bin
          '';
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                hk = prev.hk.overrideAttrs (oldAttrs: rec {
                  version = "2.0.1";
                  src = prev.fetchFromGitHub {
                    inherit (oldAttrs.src) owner repo;
                    tag = "v${version}";
                    hash = "sha256-Rfl4Ssps+2PUcwj01+srDFPjMq78ec4XWmhgMlbq7iM=";
                  };
                  cargoDeps = final.rustPlatform.fetchCargoVendor {
                    inherit src;
                    hash = "sha256-P6RV8R1hRPkBX0iAfNEiFAuVdcUfg3PpsZ1YB7s2B3E=";
                  };
                });
              })
            ];
          };
          apps = {
            deadnix = {
              type = "app";
              program = "${pkgs.deadnix}/bin/deadnix";
            };
            editorconfig-checker = {
              type = "app";
              program = "${pkgs.editorconfig-checker}/bin/editorconfig-checker";
            };
            statix = {
              type = "app";
              program = "${pkgs.statix}/bin/statix";
            };
          };
          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              deadnix
              editorconfig-checker
              hk
              nixd
              nixfmt
              pnpm
              statix
              yamllint
            ];
            shellHook = ''
              pnpm install
              export PATH="$PWD/node_modules/.bin:$PATH"
            '';
          };
          formatter = pkgs.nixfmt-tree;
        };
    };
}
