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
in {
  packages = with pkgs;
    [
      zsh
      mob
      alejandra
      openssl
      cargo-workspaces
      cargo-nextest
      playwright-test
      playwright-driver
      playwright-driver.browsers
      tailwindcss
      dbmate
    ]
    ++ lib.optionals stdenv.isLinux [
      libnotify
      inotify-tools
    ]
    ++ lib.optionals stdenv.isDarwin [
      terminal-notifier
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.CoreServices
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

  env.PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;

  tasks = {
    "zsh:install_repl" = {
      exec = ''
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
        ${cargo}/bin/cargo install evcxr
      '';
      status = "evcxr -V";

      before = ["devenv:enterShell"];
    };
    "zsh:install_bacon" = {
      exec = ''
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
        ${cargo}/bin/cargo install bacon
      '';
      status = "bacon --version";
      before = ["devenv:enterShell"];
    };
    "zsh:install_dioxus-cli" = {
      exec = ''
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
        ${cargo}/bin/cargo install dioxus-cli@0.6.1
      '';
      status = "dx --version";
      before = ["devenv:enterShell"];
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
          level-up.jwilger.slipstreamconsulting.net:3003 {
            reverse_proxy localhost:3001
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
    headache.enable = true;
    markdownlint.enable = true;
    ripsecrets.enable = true;
    rustfmt.enable = true;
    shellcheck.enable = true;
    trim-trailing-whitespace.enable = true;
    trufflehog.enable = true;
    gptcommit.enable = true;
  };
}
