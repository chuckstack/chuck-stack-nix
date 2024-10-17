{ pkgs ? import <nixpkgs> {} }:

# Prerequisites
  # install Nix package manager or use NixOS

# The purpose of this shell is to:
  # install postgresql
  # create a local psql cluster (in this directory)
  # allow you to view and interact with the results using 'psqlx'
  # destroy all artifacts upon leaving the shell

let
  # how to create a custom function/script 
  #runMigrations = pkgs.writeShellScriptBin "run-migrations" ''
  #  echo "Running migrations..."
  #  sqlx migrate run
  #'';

in pkgs.mkShell {
  buildInputs = [
    pkgs.postgresql
    #runMigrations
  ];

  shellHook = ''
    export PGDATA="$PWD/pgdata"
    export PGUSER=postgres
    #export PGDATABASE=your_custom_db # uncomment if needed
    alias psqlx="psql -h $PWD/pgdata/"
    #alias psqlx="psql -h $PWD/pgdata/ -d $PGDATABASE" # example adding database if needed

    if [ ! -d "$PGDATA" ]; then
      echo "Initializing PostgreSQL database..."
      initdb -D "$PGDATA" --no-locale --encoding=UTF8 --username=$PGUSER && echo "listen_addresses = '''" >> $PGDATA/postgresql.conf
      pg_ctl start -o "-k \"$PGDATA\"" -l "$PGDATA/postgresql.log"
      #createdb $PGDATABASE -h $PGDATA -U $PGUSER # uncomment if needed 
    else
      echo "Starting PostgreSQL..."
      pg_ctl start -o "-k \"$PGDATA\"" -l "$PGDATA/postgresql.log"
    fi

    #run-migrations # example calling above custom function/script

    echo ""
    echo "***************************************************"
    echo "PostgreSQL is running using Unix socket in $PGDATA"
    echo "To connect, issue: psqlx"
    echo "Note: this database will be destroyed on shell exit"
    echo "***************************************************"
    echo ""

    cleanup() {
      echo "Stopping PostgreSQL and cleaning up..."
      pg_ctl stop
      rm -rf "$PGDATA"
    }

    trap cleanup EXIT
  '';
}
