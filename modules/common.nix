{ pkgs, ... }: {
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
    neofetch
    htop
    ncdu
    tree
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ ];
    builders-use-substitutes = true;
  };
}
