{
  description = "A Nix-flake-based Gleam development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSytems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSytems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
      {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [ erlang_27 rebar3 gleam bacon process-compose postgresql_17 nodejs inotify-tools ];
        };
      });
    };
}
