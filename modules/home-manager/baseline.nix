{ config, lib, ... }:
with lib; let
  cfg = config.custom.baseline;
in
{
  options.custom.baseline = {
    enable = mkEnableOption "baseline configuration";
  };

  config = mkIf cfg.enable {
    programs.bash.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.git = {
      enable = true;
      userEmail = "i@rebmit.moe";
      userName = "rebmit";
      signing.key = "~/.ssh/id_ed25519";
      extraConfig = {
        commit.gpgSign = true;
        gpg = {
          format = "ssh";
        };
        init.defaultBranch = "master";
      };
    };
  };
}

