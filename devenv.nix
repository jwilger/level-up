{
  pkgs,
  unstable,
  fenix,
  lib,
  config,
  ...
}: let
  uPkgs = unstable.legacyPackages.${pkgs.system};

  fPkgs = fenix.packages.${pkgs.system}.default;
  cargo = fPkgs.cargo;
  nodejs = uPkgs.nodejs_22;
  stdenv = pkgs.stdenv;
in {
  packages =
    [
      pkgs.alejandra
      pkgs.at-spi2-atk
      pkgs.atkmm
      pkgs.cairo
      fPkgs.cargo
      pkgs.dbmate
      pkgs.gdk-pixbuf
      pkgs.glib
      pkgs.gobject-introspection
      pkgs.gtk3
      pkgs.harfbuzz
      pkgs.librsvg
      pkgs.libsoup_3
      pkgs.libz
      pkgs.mob
      pkgs.nodejs
      pkgs.openssl
      pkgs.pango
      pkgs.pkg-config
      pkgs.playwright-test
      pkgs.playwright-driver
      pkgs.playwright-driver.browsers
      pkgs.webkitgtk_4_1
      pkgs.zsh
    ]
    ++ lib.optionals stdenv.isLinux [
      pkgs.libnotify
      pkgs.inotify-tools
    ]
    ++ lib.optionals stdenv.isDarwin [
      pkgs.terminal-notifier
      pkgs.darwin.apple_sdk.frameworks.CoreFoundation
      pkgs.darwin.apple_sdk.frameworks.CoreServices
    ];

  languages = {
    rust = {
      enable = true;
      channel = "nightly";
      targets = ["wasm32-unknown-unknown"];
    };
    javascript = {
      enable = true;
      package = nodejs;
      npm.enable = true;
    };
    typescript = {
      enable = true;
    };
  };

  tasks = {
    "zsh:install_cargo_programs" = {
      exec = ''
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
        ${cargo}/bin/cargo install evcxr@0.18.0 bacon@3.6.0 dioxus-cli@0.6.1 cargo-workspaces@0.3.6 cargo-nextest@0.9.82 wasm-bindgen-cli@0.2.99
      '';
      before = ["devenv:enterShell"];
    };
  };

  processes = {
    app = {
      exec = "${cargo}/bin/cargo leptos serve";
    };
  };

  services =
    {
      postgres = {
        enable = true;
        initialScript = ''
          CREATE ROLE level_up WITH LOGIN SUPERUSER PASSWORD 'level_up';
          CREATE DATABASE level_up;
        '';
        listen_addresses = "127.0.0.1";
        port = 5432;
      };
    }
    // lib.optionalAttrs (!config.devenv.isTesting) {
      caddy = {
        enable = true;
        config = ''
          level-up.jwilger.slipstreamconsulting.net {
            reverse_proxy localhost:3000
          }
        '';
      };
    };

  git-hooks.hooks = {
    actionlint.enable = true;
    alejandra.enable = true;
    cargo-check.enable = true;
    check-case-conflicts.enable = true;
    check-executables-have-shebangs.enable = true;
    check-json = {
      enable = true;
      excludes = ["tsconfig\\.json"];
    };
    check-merge-conflicts.enable = true;
    check-symlinks.enable = true;
    check-toml.enable = true;
    check-vcs-permalinks.enable = true;
    check-xml.enable = true;
    check-yaml.enable = true;
    clippy.enable = true;
    deadnix.enable = true;
    detect-aws-credentials.enable = true;
    detect-private-keys.enable = true;
    editorconfig-checker.enable = true;
    flake-checker.enable = true;
    forbid-new-submodules.enable = true;
    hadolint.enable = true;
    markdownlint.enable = true;
    ripsecrets.enable = true;
    rustfmt.enable = true;
    shellcheck.enable = true;
    trim-trailing-whitespace.enable = true;
    trufflehog.enable = true;
    gptcommit.enable = true;
  };
}
