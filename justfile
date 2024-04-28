set shell := ["bash", "-c"]

rebuild args:
  nixos-rebuild --use-remote-sudo -v -L --flake ~/Projects/flakes {{args}}
  systemctl status home-manager-rebmit.service --no-pager

col tag:
  colmena apply --on '@{{tag}}' -v

up:
  nix flake update

upp input:
  nix flake lock --update-input {{input}}
