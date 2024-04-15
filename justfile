set shell := ["bash", "-c"]

rebuild args:
  nixos-rebuild --use-remote-sudo -v -L --flake ~/Projects/flakes {{args}}
  systemctl status home-manager-rebmit.service --no-pager
