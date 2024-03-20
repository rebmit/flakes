{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    baseIndex = 1;
    escapeTime = 10;
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "screen-256color";
    extraConfig = ''
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
      new-session -s main
    '';
  };
}
