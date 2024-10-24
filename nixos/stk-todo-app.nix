{ config, lib, pkgs, modulesPath, ... }:

# Notes:
  # discussed in https://www.chuck-stack.org/ls/stack-architecture.html
  # get list of todos via api from localhost:
    # curl http://localhost:3000/stk_todo
  # add todo via api from localhost:
    # curl http://localhost:3000/stk_todo -X POST -H "Content-Type: application/json" -d '{"name": "do great things"}'
  # get list of todos through nginx via ip -- assumes self signed (insecure)
    # curl --insecure https://10.2.2.2/stk_todo

let
  postgrestPort = 3000; # variable
  postgresUser = "postgrest";
  postgresDb = "stk_todo_db";
  run-migrations = pkgs.writeScriptBin "run-migrations" ''
    #!${pkgs.bash}/bin/bash
    set -e

    # Set your database URL
    export DATABASE_URL="postgres:///stk_todo_db"

    # Set the Git repository URL and the local path where it should be cloned
    REPO_URL="https://github.com/chuckstack/stk-todo-app-sql.git"
    CLONE_PATH="/tmp/db-migrations"

    # Ensure the clone directory is empty
    rm -rf "$CLONE_PATH"

    # Clone the repository
    ${pkgs.git}/bin/git clone "$REPO_URL" "$CLONE_PATH"

    # Change to the cloned directory
    cd "$CLONE_PATH"

    # Run the migrations
    ${pkgs.sqlx-cli}/bin/sqlx migrate run

    # Clean up
    cd /
    rm -rf "$CLONE_PATH"
  '';
in
{
  # PostgreSQL configuration
  services.postgresql = {
    ensureDatabases = [ "stk_todo_db" ];
  };

  environment.systemPackages = [ run-migrations pkgs.git pkgs.sqlx-cli ];

  systemd.services.stk-todo-db-migrations = {
    description = "Clone migration repo and run database migrations";
    after = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStart = "${run-migrations}/bin/run-migrations";
    };
  };

  users.users = {
    # Service user without login capabilities
    postgrest = {
      isSystemUser = true;
      group = "postgrest";
      description = "User for running the postgREST service";

      # uncomment these lines if you need the user to have a home
      home = "/var/lib/postgrest";
      createHome = true;
      shell = pkgs.bashInteractive;  # or pkgs.nologin if you want to prevent interactive login

    };
  };

  # Create a group for the service user
  users.groups.postgrest = {};

  # Create Postgrest configuration file directly in the Nix configuration
  environment.etc."postgrest.conf" = {
    text = ''
      db-uri = "postgres://${postgresUser}@/${postgresDb}?host=/run/postgresql"
      db-schema = "api"
      db-anon-role = "postgrest_web_anon"
      server-port = ${toString postgrestPort}
      # jwt-secret = "your-jwt-secret"
      # max-rows = 1000

      # Add any other Postgrest configuration options here
    '';
    mode = "0600";  # More restrictive permissions due to sensitive information

  };

  system.activationScripts = {
    postgrestConf = ''
      chown postgrest:postgrest /etc/postgrest.conf
    '';
  };

  systemd.services.postgrest = {
    description = "PostgREST Service";
    after = [ "network.target" "postgresql.service" "stk-todo-db-migrations.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.postgrest}/bin/postgrest /etc/postgrest.conf";
      Restart = "always";
      RestartSec = "10s";
      User = "postgrest";
      Group = "postgrest";
    };
  };

  # Open firewall for PostgREST
  networking.firewall.allowedTCPPorts = [ postgrestPort ];
}
