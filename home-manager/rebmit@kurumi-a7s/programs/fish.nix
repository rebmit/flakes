{pkgs, ...}: {
  programs.fish = {
    shellAliases = {
      p = "powerprofilesctl";
    };
  };
}
