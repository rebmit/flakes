{
  writeShellApplication,
  socat,
}:
writeShellApplication {
  name = "hyprland-scratchpad-helper";
  text = ''
    function handle {
      case "$1" in
        "activespecial>>"*)
          echo "$1"
          workspace=$(echo "$1" | sed 's/activespecial>>//g' | cut -d "," -f 1)
          if [[ -z "$workspace" ]]; then
            hyprctl dispatch submap reset
          elif [[ "$workspace" != "special" ]]; then
            hyprctl dispatch submap scratchpad
          fi
        ;;
      esac
    }

    ${socat}/bin/socat -U - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line
    do
      handle "$line"
    done
  '';
}
