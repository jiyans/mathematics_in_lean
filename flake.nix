{
  description = "Lean 4 Mathematics in Lean development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Elan (Lean version manager) - will manage Lean versions
            elan
            
            # Git for version control
            git
            
            # Additional development tools
            curl
            wget
            
            # Language server protocol support
            nodePackages.vscode-langservers-extracted
            
            # Optional: text editors with Lean support
            # vscode-with-extensions
            # emacs
          ];

          shellHook = ''
            echo "🎯 Lean 4 Development Environment"
            echo "================================"
            
            # Ensure elan is properly set up for this project
            if command -v elan >/dev/null 2>&1; then
              echo "Setting up Lean toolchain..."
              if [ -f lean-toolchain ]; then
                elan override set $(cat lean-toolchain)
                echo "Elan version: $(elan --version)"
                echo "Lean version: $(lean --version 2>/dev/null || echo 'Setting up...')"
                echo "Lake version: $(lake --version 2>/dev/null || echo 'Setting up...')"
              fi
            else
              echo "Elan not found - please check installation"
            fi
            echo ""
            echo "📚 Project info:"
            echo "  - Mathematics in Lean workspace"
            echo "  - Lean toolchain: $(cat lean-toolchain 2>/dev/null || echo 'Not specified')"
            echo "  - Mathlib dependency configured"
            echo ""
            echo "🚀 Quick start:"
            echo "  lake build      # Build the project"
            echo "  lake exe cache get  # Download mathlib cache"
            echo "  lake test       # Run tests"
            echo ""
          '';

          # Environment variables
          LEAN_PATH = ".";
          
          # Ensure elan's binaries are in PATH
          shellInit = ''
            export PATH="$HOME/.elan/bin:$PATH"
          '';
        };

        # Optional: provide packages that can be built
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "mathematics-in-lean";
          version = "0.1.0";
          src = ./.;
          
          buildInputs = [ pkgs.lean4 ];
          
          buildPhase = ''
            lake build
          '';
          
          installPhase = ''
            mkdir -p $out
            cp -r .lake/build $out/
          '';
        };
      });
}