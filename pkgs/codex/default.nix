{ pkgs }:
let
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    ps.openai
    ps.rich
  ]);
in
pkgs.writeShellApplication {
  name = "codex";
  runtimeInputs = [ pythonEnv ];
  text = ''
    export PYTHONUTF8=1
    exec ${pythonEnv}/bin/python ${./codex.py} "$@"
  '';
}
