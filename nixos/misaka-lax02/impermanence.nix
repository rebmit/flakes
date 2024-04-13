{ inputs, ... }: {
  environment.persistence."/persist" = {
    directories = [
      "/var"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
