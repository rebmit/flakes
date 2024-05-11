# https://github.com/NixOS/nixpkgs/pull/258250
# https://github.com/NixOS/nixpkgs/pull/299409
{ lib }:
with lib;
let
  cidrToIpAddress = cidr: lib.elemAt (lib.splitString "/" cidr) 0;
  cidrToPrefixLength = cidr: (strings.toInt (lib.elemAt (lib.splitString "/" cidr) 1));
  wireguard = rec {
    getAddrByFamily = network: nodeName: addressFamily:
      if addressFamily == "ip4" then
        network.nodes."${nodeName}".meta.wireguard.publicIpv4
      else
        network.nodes."${nodeName}".meta.wireguard.publicIpv6;
    getLinks = network: hostName: builtins.filter
      (value: value.srcName == hostName)
      (
        lists.imap0
          (index: value:
            rec {
              inherit (value) addressFamily;
              sendPort = network.meta.wireguard.basePort + index;
              persistentKeepalive =
                let
                  srcAddr = getAddrByFamily value.srcName addressFamily;
                  destAddr = getAddrByFamily value.destName addressFamily;
                in
                if srcAddr == null || destAddr == null then 25 else null;
            } // (if (value.destName == hostName) then {
              srcName = value.destName;
              destName = value.srcName;
            } else {
              inherit (value) srcName destName;
            })
          )
          network.links
      );
    getPeers = network: hostName: builtins.map
      (link: rec {
        inherit (link) sendPort addressFamily persistentKeepalive;
        publicKey = network.nodes."${link.destName}".meta.wireguard.publicKey;
        endpoint =
          let
            address = getAddrByFamily network link.destName addressFamily;
          in
          if address == null then null else "${address}:${toString sendPort}";
      })
      (getLinks network hostName);
  };
  prefixLengthToMask6 = len:
    let
      div = len / 4;
      rem = len - div * 4;
      groupDiv = div / 4;
      groupRem = div - groupDiv * 4;
      dict = { "0" = ""; "1" = "1"; "2" = "3"; "3" = "7"; };
      head = dict.${toString rem} + (strings.replicate groupRem "f");
      prefix =
        if groupDiv == 8 || (groupDiv == 7 && head != "") then ""
        else if head == "" && (groupDiv != 0) then ":"
        else "::";
    in
    if len == 128 then
      "ffff" + (strings.replicate 7 ":ffff")
    else prefix + head + (strings.replicate groupDiv ":ffff");
in
{
  ipv4 = {
    inherit
      cidrToIpAddress
      cidrToPrefixLength
      ;
  };

  ipv6 = {
    inherit
      cidrToIpAddress
      cidrToPrefixLength
      ;
    prefixLengthToMask = prefixLengthToMask6;
  };

  inherit wireguard;
}
