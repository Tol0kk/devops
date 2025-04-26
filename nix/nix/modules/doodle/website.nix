{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption mkOption mkIf;
  inherit (lib.types) str int bool;

  cfg = config.modules.doodle.website;
  package = cfg.package.override {
    inherit (cfg) port;
  };
in {
  options.modules.doodle.website = {
    enable = mkEnableOption "Enable Doodle Website modules";
    package = mkPackageOption pkgs "doodle-front-server" {};
    port = mkOption {
      type = int;
      default = 8742;
      description = "Port number Doodle Website will be listening on, only on TCP.";
    };
    user = mkOption {
      type = str;
      default = "doodle-website";
      description = "User account under which doodle-website runs.";
    };

    group = mkOption {
      type = str;
      default = "doodle-website";
      description = "Group under which doodle-website runs.";
    };
    openFirewall = mkOption {
      type = bool;
      default = false;
      description = ''
        Open the ports in the firewall for the website.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Define systems users
    users.users = mkIf (cfg.user == "doodle-website") {
      doodle-website = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    # Define systems groups
    users.groups = mkIf (cfg.group == "doodle-website") {
      doodle-website = {};
    };

    systemd.services.doodle-website = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      description = "Start teh doodle application website";
      serviceConfig = {
        ExecStart = ''${package}/bin/doodle-front-server'';
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        (builtins.toString cfg.port)
      ];
    };
  };
}
