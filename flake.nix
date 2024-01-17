{
  description = "A fuzzy Tmux session manager with preview capabilities, deleting, renaming and more!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        lib,
        ...
      }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "sessionx";
          version = "20240107";

          src = pkgs.fetchFromGitHub {
            owner = "omerxx";
            repo = "tmux-sessionx";
            rev = "a87122c8f4bd2eb19c3ae556e2aad2973e2ca37c";
            hash = "sha256-/VZyEIxqIn0ISgZ6u5TcYcXWRE+6SDK5JK1W34lKIKk=";
          };
          nativeBuildInputs = [ pkgs.makeWrapper ];

          postPatch = ''
            substituteInPlace sessionx.tmux \
              --replace "\$CURRENT_DIR/scripts/sessionx.sh" "$out/share/tmux-plugins/sessionx/scripts/sessionx.sh"
            substituteInPlace scripts/sessionx.sh \
              --replace "/tmux-sessionx/scripts/preview.sh" "$out/share/tmux-plugins/sessionx/scripts/preview.sh"
          '';

          postInstall = ''
            chmod +x $target/scripts/sessionx.sh
            wrapProgram $target/scripts/sessionx.sh \
              --prefix PATH : ${with pkgs; lib.makeBinPath [ zoxide fzf gnugrep gnused coreutils ]}
            chmod +x $target/scripts/preview.sh
            wrapProgram $target/scripts/preview.sh \
              --prefix PATH : ${with pkgs; lib.makeBinPath [ coreutils gnugrep gnused ]}
          '';

          meta = with lib; {
            description = "A fuzzy Tmux session manager with preview capabilities, deleting, renaming and more!";
            homepage = "https://github.com/omerxx/tmux-sessionx";
            platforms = platforms.all;
          };
        };
      };
    };
}
