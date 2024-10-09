{ config, lib, pkgs, modulesPath, ... }:

let
  postgrestPort = 3000; # variable
  postgresUser = "postgrest";
  postgresDb = "mydb";
in
{
  # ... other configurations ...

  # Create PostgREST configuration file directly in the Nix configuration
  environment.etc."postgrest.conf" = {
    text = ''
      # db-uri = "postgres://${postgresUser}@//${postgresDb}?host=/var/run/postgresql"
      db-uri = "postgres://username:password@/database_name?host=/var/run/postgresql"
      db-schema = "public"
      db-anon-role = "postgrest_web_anon"
      server-port = ${toString postgrestPort}
      # jwt-secret = "your-jwt-secret"
      # max-rows = 1000

      # Add any other PostgREST configuration options here
    '';
    mode = "0600";  # More restrictive permissions due to sensitive information
  };

  systemd.services.postgrest = {
    description = "PostgREST Service";
    after = [ "network.target" "postgresql.service" ];
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

  # ... other configurations ...
}

# using unix sockets
# postgres:///your_database_name?host=/var/run/postgresql
#   1. `postgres://`: This is the scheme, indicating that it's a PostgreSQL connection.
#   2. `///`: The triple slash indicates that we're not specifying a host or port.
#   3. `your_database_name`: Replace this with the actual name of your database.
#   4. `?host=/var/run/postgresql`: This query parameter specifies the path to the Unix socket directory. `/var/run/postgresql` is the default location on many systems, but it might be different depending on your PostgreSQL installation.

# If you need to specify a user or password, you can modify the URI like this:
# postgres://username:password@/database_name?host=/var/run/postgresq
