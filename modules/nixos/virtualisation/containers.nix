{ config, lib, pkgs, ... } @ host:
with lib;
let
  configurationDirectoryName = "custom-containers";
  configurationDirectory = "/etc/custom-containers";
  stateDirectory = "/var/lib/custom-containers";

  containerInit = cfg:
    let
      renderExtraVeth = name: cfg:
        ''
          echo "Bringing ${name} up"
          ip link set dev ${name} up
        '';
    in
    pkgs.writeScript "container-init"
      ''
        #! ${pkgs.runtimeShell} -e
        trap "exit 0" SIGRTMIN+3
        ${concatStringsSep "\n" (mapAttrsToList renderExtraVeth cfg.extraVeths)}
        set +e
        . "$1"
      '';

  nspawnExtraVethArgs = (name: cfg: "--network-veth-extra=${name}");

  startScript = cfg:
    ''
      mkdir -p -m 0755 "$root/etc" "$root/var/lib"
      mkdir -p -m 0700 "$root/var/lib/private" "$root/root" /run/custom-containers
      if ! [ -e "$root/etc/os-release" ]; then
        touch "$root/etc/os-release"
      fi

      if ! [ -e "$root/etc/machine-id" ]; then
        touch "$root/etc/machine-id"
      fi

      mkdir -p -m 0755 \
        "/nix/var/nix/profiles/per-container/$INSTANCE" \
        "/nix/var/nix/gcroots/per-container/$INSTANCE"

      cp --remove-destination /etc/resolv.conf "$root/etc/resolv.conf"

      if [ "$PRIVATE_NETWORK" = 1 ]; then
        extraFlags+=" --private-network"
      fi

      extraFlags+=" ${concatStringsSep " " (mapAttrsToList nspawnExtraVethArgs cfg.extraVeths)}"

      export SYSTEMD_NSPAWN_UNIFIED_HIERARCHY=1

      exec ${config.systemd.package}/bin/systemd-nspawn \
        --keep-unit \
        -M "$INSTANCE" -D "$root" $extraFlags \
        $EXTRA_NSPAWN_FLAGS \
        --notify-ready=yes \
        --kill-signal=SIGRTMIN+3 \
        --bind-ro=/nix/store \
        --bind-ro=/nix/var/nix/db \
        --bind-ro=/nix/var/nix/daemon-socket \
        --bind="/nix/var/nix/profiles/per-container/$INSTANCE:/nix/var/nix/profiles:rootidmap" \
        --bind="/nix/var/nix/gcroots/per-container/$INSTANCE:/nix/var/nix/gcroots:rootidmap" \
        ${optionalString (!cfg.privileged) "-U"} \
        ${optionalString (!cfg.ephemeral) "--link-journal=try-guest"} \
        --setenv PATH="$PATH" \
        ${optionalString cfg.ephemeral "--ephemeral"} \
        ${optionalString (cfg.additionalCapabilities != null && cfg.additionalCapabilities != [])
          ''--capability="${concatStringsSep "," cfg.additionalCapabilities}"''
        } \
        ${containerInit cfg} "''${SYSTEM_PATH:-/nix/var/nix/profiles/system}/init"
    '';

  preStartScript = cfg:
    ''
      machinectl terminate "$INSTANCE" 2> /dev/null || true

      ${concatStringsSep "\n" (
        mapAttrsToList (name: cfg:
          "ip link del dev ${name} 2> /dev/null || true "
        ) cfg.extraVeths
      )}
    '';

  postStartScript = cfg:
    let
      renderExtraVeth = name: cfg:
        if cfg.hostBridge != null then
          ''
            # Add ${name} to bridge ${cfg.hostBridge}
            ip link set dev ${name} master ${cfg.hostBridge} up
          ''
        else
          ''
            echo "Bring ${name} up"
            ip link set dev ${name} up
          '';
    in
    ''
      ${concatStringsSep "\n" (mapAttrsToList renderExtraVeth cfg.extraVeths)}
    '';

  serviceDirectives = cfg: {
    ExecReload = pkgs.writeScript "reload-container"
      ''
        #! ${pkgs.runtimeShell} -e
        ${config.systemd.package}/bin/machinectl shell "$INSTANCE" \
          /usr/bin/env bash --login -c "''${SYSTEM_PATH:-/nix/var/nix/profiles/system}/bin/switch-to-configuration test"
      '';
    SyslogIdentifier = "container %i";
    EnvironmentFile = "-${configurationDirectory}/%i.conf";
    Type = "notify";
    RuntimeDirectory = lib.optional cfg.ephemeral "${configurationDirectoryName}/%i";
    RestartForceExitStatus = "133";
    SuccessExitStatus = "133";
    TimeoutStartSec = cfg.timeoutStartSec;
    Restart = "on-failure";
    Slice = "machine.slice";
    Delegate = true;
    KillMode = "mixed";
    KillSignal = "TERM";
    DevicePolicy = "closed";
    DeviceAllow = map (d: "${d.node} ${d.modifier}") cfg.allowedDevices;
  };

  bindMountOpts = { name, ... }: {
    options = {
      mountPoint = mkOption {
        type = types.str;
      };
      hostPath = mkOption {
        default = null;
        type = types.nullOr types.str;
      };
      isReadOnly = mkOption {
        default = true;
        type = types.bool;
      };
      useRootIdMap = mkOption {
        default = true;
        type = types.bool;
      };
    };

    config = {
      mountPoint = mkDefault name;
    };
  };

  allowedDeviceOpts = { ... }: {
    options = {
      node = mkOption {
        type = types.str;
      };
      modifier = mkOption {
        example = "rwm";
        type = types.str;
      };
    };
  };

  extraVethOpts = { ... }: {
    options = {
      hostBridge = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  mkBindFlag = d:
    let
      flagPrefix = if d.isReadOnly then " --bind-ro=" else " --bind=";
      flagSuffix = if d.useRootIdMap then ":rootidmap" else "";
      mountstr = if d.hostPath != null then "${d.hostPath}:${d.mountPoint}" else "${d.mountPoint}:${d.mountPoint}";
    in
    flagPrefix + mountstr + flagSuffix;

  mkBindFlags = bs: concatMapStrings mkBindFlag (lib.attrValues bs);

  dummyConfig = {
    extraVeths = { };
    additionalCapabilities = [ ];
    ephemeral = false;
    timeoutStartSec = "1min";
    allowedDevices = [ ];
    privileged = false;
  };
in
{
  options.custom.virtualisation = {
    containersSpecialArgs = mkOption {
      type = types.attrsOf types.unspecified;
      default = { };
    };
    containers = mkOption {
      type = types.attrsOf (types.submodule (
        { config, options, name, ... }: {
          options = {
            config = mkOption {
              type = lib.mkOptionType {
                name = "Toplevel NixOS config";
                merge = loc: defs: (import "${toString config.nixpkgs}/nixos/lib/eval-config.nix" {
                  modules =
                    let
                      extraConfig = { options, ... }: {
                        _file = "module at ${__curPos.file}:${toString __curPos.line}";
                        config = {
                          nixpkgs =
                            if options.nixpkgs?hostPlatform && host.options.nixpkgs.hostPlatform.isDefined
                            then { inherit (host.config.nixpkgs) hostPlatform; }
                            else { inherit (host.config.nixpkgs) localSystem; }
                          ;
                          boot.isContainer = true;
                          networking.hostName = mkDefault name;
                          networking.useDHCP = false;
                          networking.firewall.enable = lib.mkDefault false;
                          services.resolved.enable = false;
                        };
                      };
                    in
                    [ extraConfig ] ++ (map (x: x.value) defs);
                  prefix = [ "containers" name ];
                  inherit (config) specialArgs;
                  system = null;
                }).config;
              };
            };

            path = mkOption {
              type = types.path;
            };

            additionalCapabilities = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };

            nixpkgs = mkOption {
              type = types.path;
              default = pkgs.path;
            };

            specialArgs = mkOption {
              type = types.attrsOf types.unspecified;
              default = host.config.custom.virtualisation.containersSpecialArgs;
            };

            ephemeral = mkOption {
              type = types.bool;
              default = false;
            };

            privateNetwork = mkOption {
              type = types.bool;
              default = false;
            };

            privileged = mkOption {
              type = types.bool;
              default = false;
            };

            extraVeths = mkOption {
              type = with types; attrsOf (submodule extraVethOpts);
              default = { };
            };

            autoStart = mkOption {
              type = types.bool;
              default = false;
            };

            restartIfChanged = mkOption {
              type = types.bool;
              default = true;
            };

            timeoutStartSec = mkOption {
              type = types.str;
              default = "1min";
            };

            bindMounts = mkOption {
              type = with types; attrsOf (submodule bindMountOpts);
              default = { };
            };

            allowedDevices = mkOption {
              type = with types; listOf (submodule allowedDeviceOpts);
              default = [ ];
            };

            extraFlags = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
          };

          config = {
            path = mkIf options.config.isDefined config.config.system.build.toplevel;
          };
        }
      ));

      default = { };
    };
  };

  config =
    let
      unit = {
        description = "Container '%i'";
        unitConfig.RequiresMountsFor = "${stateDirectory}/%i";
        path = [ pkgs.iproute2 ];
        environment = {
          root = "${stateDirectory}/%i";
          INSTANCE = "%i";
        };
        preStart = preStartScript dummyConfig;
        script = startScript dummyConfig;
        postStart = postStartScript dummyConfig;
        restartIfChanged = false;
        serviceConfig = serviceDirectives dummyConfig;
      };
    in
    {
      boot.enableContainers = false;

      systemd.targets.multi-user.wants = [ "machines.target" ];

      systemd.services = listToAttrs (filter (x: x.value != null) (
        [{ name = "custom-container@"; value = unit; }]
        ++ (mapAttrsToList
          (name: cfg: nameValuePair "custom-container@${name}" (
            recursiveUpdate unit
              {
                preStart = preStartScript cfg;
                script = startScript cfg;
                postStart = postStartScript cfg;
                serviceConfig = serviceDirectives cfg;
                unitConfig.RequiresMountsFor = lib.optional (!cfg.ephemeral) "${stateDirectory}/%i";
                environment.root = if cfg.ephemeral then "/run/custom-containers/%i" else "${stateDirectory}/%i";
              } // (
              optionalAttrs cfg.autoStart
                {
                  wantedBy = [ "machines.target" ];
                  wants = [ "network.target" ];
                  after = [ "network.target" ];
                  restartTriggers = [
                    cfg.path
                    config.environment.etc."${configurationDirectoryName}/${name}.conf".source
                  ];
                  restartIfChanged = cfg.restartIfChanged;
                }
            )
          ))
          config.custom.virtualisation.containers)
      ));

      environment.etc = mapAttrs'
        (name: cfg: nameValuePair "${configurationDirectoryName}/${name}.conf"
          {
            text =
              ''
                SYSTEM_PATH=${cfg.path}
                ${optionalString cfg.privateNetwork ''
                  PRIVATE_NETWORK=1
                ''}
                ${optionalString cfg.autoStart ''
                  AUTO_START=1
                ''}
                EXTRA_NSPAWN_FLAGS="${mkBindFlags cfg.bindMounts +
                  optionalString (cfg.extraFlags != [])
                    (" " + concatStringsSep " " cfg.extraFlags)}"
              '';
          })
        config.custom.virtualisation.containers;

      networking.dhcpcd.denyInterfaces = [ "ve-*" "vb-*" ];

      services.udev.extraRules = optionalString config.networking.networkmanager.enable ''
        # Don't manage interfaces created by nixos-container.
        ENV{INTERFACE}=="v[eb]-*", ENV{NM_UNMANAGED}="1"
      '';

      boot.kernelModules = [
        "bridge"
        "tap"
        "tun"
      ];
    };
}
