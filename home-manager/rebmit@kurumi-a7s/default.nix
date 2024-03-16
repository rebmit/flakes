{
  pkgs,
  mylib,
  ...
}: {
  imports = [
    ../rebmit

    ./programs
    ./services
  ];
}
