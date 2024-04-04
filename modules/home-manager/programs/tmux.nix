{ pkgs, config, lib, ... }:
with lib; let
  cfg = config.custom.programs.tmux;
in
{
  options.custom.programs.tmux = {
    enable = mkEnableOption "terminal multiplexer";
    shell = mkOption {
      type = types.str;
      default = "${pkgs.fish}/bin/fish";
    };
    enableFishIntegration = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      escapeTime = 10;
      keyMode = "vi";
      mouse = true;
      shell = "${cfg.shell}";
      terminal = "screen-256color";
      plugins = with pkgs; [
        tmuxPlugins.yank
        tmuxPlugins.open
      ];
      extraConfig = ''
        # global
        unbind -n MouseDrag1Pane
        unbind -Tcopy-mode MouseDrag1Pane
        unbind %
        unbind "'"
        set -g history-limit 50000
        set -s extended-keys on
        set -g bell-action none
        set -g focus-events on

        # keybind
        set -g prefix C-b
        bind C-b send-prefix
        bind \; command-prompt
        bind p paste-buffer
        bind C-p choose-buffer
        ${optionalString (cfg.enableFishIntegration) ''
          bind -n C-k if "test '#{pane_current_command}' = 'fish'" "copy-mode; send -N 5 -X cursor-up"   "send C-k"
          bind -n C-j if "test '#{pane_current_command}' = 'fish'" "copy-mode; send -N 5 -X cursor-down" "send C-j"
        ''}

        # pane
        bind -r k select-pane -U
        bind -r j select-pane -D
        bind -r h select-pane -L
        bind -r l select-pane -R
        bind -r C-k resize-pane -U 5
        bind -r C-j resize-pane -D 5
        bind -r C-h resize-pane -L 5
        bind -r C-l resize-pane -R 5
        bind -r H swap-pane -d -t -1
        bind -r L swap-pane -d -t +1
        bind -r x kill-pane

        # window
        set -g renumber-windows on
        bind -r [ previous-window
        bind -r ] next-window
        bind -r C-[ swap-window -d -t -1
        bind -r C-] swap-window -d -t +1
        bind -r - split-window -h -c "#{pane_current_path}"
        bind -r = split-window -v -c "#{pane_current_path}"
        bind C-x kill-window
        bind c new-window -c "#{pane_current_path}"
        bind r command-prompt "rename-window %%"

        # session
        bind q confirm-before -p "kill-session #S? (y/n)" kill-session
        bind R command-prompt "rename-session %%"

        # copy mode
        bind Escape copy-mode
        bind -T copy-mode-vi k send -X cursor-up
        bind -T copy-mode-vi K send -N 5 -X cursor-up
        bind -T copy-mode-vi j send -X cursor-down
        bind -T copy-mode-vi J send -N 5 -X cursor-down
        bind -T copy-mode-vi h send -X cursor-left
        bind -T copy-mode-vi H send -N 5 -X cursor-left
        bind -T copy-mode-vi C-h send -X start-of-line
        bind -T copy-mode-vi l send -X cursor-right
        bind -T copy-mode-vi L send -N 5 -X cursor-right
        bind -T copy-mode-vi C-l send -X end-of-line
        bind -T copy-mode-vi v send -X begin-selection
        
        # image preview
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM
      '';
    };
  };
}
