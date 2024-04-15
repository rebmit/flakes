# https://github.com/NixOS/nixpkgs/pull/258250
# https://github.com/NixOS/nixpkgs/pull/299409
{ lib }:
let
  cidrToIpAddress = cidr: lib.elemAt (lib.splitString "/" cidr) 0;
  cidrToPrefixLength = cidr: lib.elemAt (lib.splitString "/" cidr) 1;
in
{
  ipv4 = {
    inherit
      cidrToIpAddress
      cidrToPrefixLength
      ;
  };
}
