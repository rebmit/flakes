{ pkgs, mysecrets, ... }: {
  security.pki.certificateFiles = [
    mysecrets.certificates.ca
  ];

  environment.systemPackages = with pkgs; [
    # vcs
    git
    git-lfs

    # networking
    mtr
    iperf3
    dnsutils
    ldns
    wget
    curl
    aria2
    socat
    nmap
    ipcalc

    # misc
    fastfetch
    htop
    ncdu
    tree
    just
    rsync
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ ];
  };
}
