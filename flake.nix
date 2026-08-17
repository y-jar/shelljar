{
  description = "shelljar - my custom Quickshell desktop shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Bundles QML, resources, and helper scripts, then wraps quickshell.
      shelljar = pkgs.runCommand "shelljar" { } ''
        mkdir -p $out/qml $out/resources $out/bin $out/libexec

        cp -r ${./qml}/* $out/qml/
        cp -r ${./resources}/* $out/resources/

        # helper scripts (stat polling, wallpaper cycling, app listing)
        for s in ${./scripts}/*; do
          install -Dm755 "$s" $out/libexec/$(basename "$s")
        done

        # main launcher: `shelljar` runs the shell
        cat > $out/bin/shelljar <<EOF
        #!${pkgs.runtimeShell}
        export SHJ_ROOT=$out
        export PATH=$out/libexec:\$PATH
        exec ${pkgs.quickshell}/bin/quickshell -p $out/qml "\$@"
        EOF
        chmod +x $out/bin/shelljar

        # ipc controller: `shelljar ipc call shelljar <function> [args]`
        cat > $out/bin/shjctl <<EOF
        #!${pkgs.runtimeShell}
        export SHJ_ROOT=$out
        exec ${pkgs.quickshell}/bin/quickshell -p $out/qml ipc call shelljar "\$@"
        EOF
        chmod +x $out/bin/shjctl

        # dev launcher: run straight from the source tree
        cat > $out/bin/shelljar-dev <<EOF
        #!${pkgs.runtimeShell}
        export SHJ_ROOT=\$(pwd)
        export PATH=\$(pwd)/scripts:\$PATH
        exec ${pkgs.quickshell}/bin/quickshell -p ${./qml} "\$@"
        EOF
        chmod +x $out/bin/shelljar-dev
      '';
    in
    {
      packages.${system} = {
        inherit shelljar;
        default = shelljar;
      };
    };
}