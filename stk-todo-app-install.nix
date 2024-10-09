{ config, lib, pkgs, modulesPath, ... }:

let
  run-migrations = pkgs.writeScriptBin "run-migrations" ''
    #!${pkgs.bash}/bin/bash
    set -e

    # Create the 'root' role with login privileges
    ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/psql -c "CREATE ROLE IF NOT EXISTS root WITH LOGIN" 
    ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/psql -c "CREATE DATABASE IF NOT EXISTS stk_todo_db OWNER root" 
    ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/psql -d stk_todo_db -c "ALTER USER root SET search_path TO public" 

    # Set your database URL
    export DATABASE_URL="postgres:///stk_todo_db"

    # Set the Git repository URL and the local path where it should be cloned
    REPO_URL="https://github.com/chuckstack/chuck-stack-todo-app.git"
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
  environment.systemPackages = [ run-migrations pkgs.git pkgs.sqlx-cli ];

  systemd.services.db-migrations = {
    description = "Clone migration repo and run database migrations";
    after = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStart = "${run-migrations}/bin/run-migrations";
    };
  };

  # Ensure postgres user has necessary permissions - do not believe this is necessary - and it can make the server less secure
  # users.users.postgres.extraGroups = [ "users" ];
}
