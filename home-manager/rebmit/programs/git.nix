{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.git;
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
}
