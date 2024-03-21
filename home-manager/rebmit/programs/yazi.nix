{ pkgs, ... }: {
  programs.fish.interactiveShellInit = ''
    function yazi
      set tmp (mktemp -t "yazi-cwd.XXXXX")
      ${pkgs.yazi}/bin/yazi $argv --cwd-file="$tmp"
      if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        echo "switching working directory to $cwd"
        cd -- "$cwd"
      end
      rm -f -- "$tmp"
    end
    alias ra yazi
  '';

  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    settings = {
      manager = {
        ratio = [ 1 4 3 ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = false;
        show_symlink = true;
      };
      preview = {
        tab_size = 2;
        max_width = 1000;
        max_height = 1000;
      };
      opener = {
        audio_default = [ ];
        image_default = [ ];
        video_default = [ ];
        text_default = [ ];
        reader_default = [ ];
      };
    };
  };
}
