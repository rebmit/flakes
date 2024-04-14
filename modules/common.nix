{ pkgs, inputs, ... }: {
  security.pki.certificateFiles = [
    inputs.mysecrets.certificates.ca
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
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ ];
  };
}
