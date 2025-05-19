{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption mkOption mkIf;
  inherit (lib.types) str;

  cfg = config.modules.doodle.backend;
in {
  options.modules.doodle.backend = {
    enable = mkEnableOption "Enable Doodle backend modules";
    package = mkPackageOption pkgs "doodle-api-server" {};
    user = mkOption {
      type = str;
      default = "doodle-backend";
      description = "User account under which doodle-backend runs.";
    };
    group = mkOption {
      type = str;
      default = "doodle-backend";
      description = "Group under which doodle-backend runs.";
    };
  };

  config = mkIf cfg.enable {
    # Define systems users
    users.users = mkIf (cfg.user == "doodle-backend") {
      doodle-backend = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    # Define systems groups
    users.groups = mkIf (cfg.group == "doodle-backend") {
      doodle-backend = {};
    };

    systemd.services.doodle-backend = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      description = "Start teh doodle application backend";
      serviceConfig = {
        ExecStart = ''${cfg.package}/bin/doodle-api-server'';
      };
    };
  };
}
