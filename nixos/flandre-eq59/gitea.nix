{ ... }: {
  services.gitea = {
    enable = true;
    lfs.enable = true;
    database.type = "postgres";
  };
}
