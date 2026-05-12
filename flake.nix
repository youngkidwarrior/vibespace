{
  description = "Vibespace development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bun-overlay = {
      url = "github:0xbigboss/bun-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    tilt-overlay = {
      url = "github:0xbigboss/tilt-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    bun-overlay,
    tilt-overlay,
    ...
  } @ inputs: let
    overlays = [
      bun-overlay.overlays.default
      tilt-overlay.overlays.default
    ];

    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = builtins.foldl' (acc: overlay: acc.extend overlay)
          nixpkgs.legacyPackages.${system}
          overlays;
      in {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          name = "vibespace-dev";
          nativeBuildInputs = [
            # Runtime and package management
            pkgs.bun
            pkgs.nodejs_20

            # Backend, database, and Kubernetes tooling
            pkgs.k3d
            pkgs.kubectl
            pkgs.kubernetes-helm
            pkgs.postgresql_16
            pkgs.tilt
            pkgs.watchman

            # Utilities
            pkgs.direnv
            pkgs.jq
            pkgs.ripgrep
            pkgs.curl
          ];
          shellHook = ''
            export COREPACK_HOME="$PWD/.corepack"
            export YARN_ENABLE_GLOBAL_CACHE=false
            export YARN_CACHE_FOLDER="$PWD/.yarn/cache"
            mkdir -p "$COREPACK_HOME/shims"
            corepack enable --install-directory "$COREPACK_HOME/shims" >/dev/null 2>&1 || true
            export PATH="$COREPACK_HOME/shims:$PATH"

            echo "Vibespace development environment ready"
            echo "  bun $(bun --version)"
            echo "  node $(node --version)"
            echo "  tilt $(tilt version)"
            echo ""
            echo "Quick start:"
            echo "  yarn install"
            echo "  yarn localnet:up"
          '';
        };

        devShell = self.devShells.${system}.default;
      }
    );
}
