{ config, lib, pkgs, modulesPath, ... }:

{
services.postgresql = {
     settings = {
       listen_addresses = "*";
     };
     enable = true;
     enableTCPIP = true;
     authentication = pkgs.lib.mkOverride 10 ''
 # allow local OS users to connect if user exists on the db
 local all       all     peer
 
 # allow local connections via ipv4 - uncomment the following line if needed
 # host all all      127.0.0.1/32      scram-sha-256
 
 # allow local connections via ipv6 - uncomment the following line if needed
 # host all all      ::1/128      scram-sha-256
 
 # allow local connections via ipv4 for postgres user - uncomment the following line if needed
 # host all postgres 127.0.0.1/32 scram-sha-256

 # all remote ipv4 to connect - uncomment the following line if needed
 # host   all     all     0.0.0.0/0       scram-sha-256

 # all remote ipv6 to connect - uncomment the following line if needed
 # host   all     all     ::/0       scram-sha-256
     '';
   };
}

# the above configures all local users (with a user on the db) to connect using psql
# the below notes gives instructions on how to add root as a db user so they can use the default postgres db for quick testing

# from sudo -u postgres psql
#    create role root with login;
#    GRANT CONNECT ON DATABASE postgres TO root;
#    GRANT USAGE ON SCHEMA public TO root;
#    GRANT create ON SCHEMA public TO root;
#    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO root;
#    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO root;
#    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO root;
#    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO root;
#    ALTER USER root SET search_path TO public;

# in cli:
#    echo "export PGDATABASE=postgres" >> ~/.bashrc
#    #restart the shell then type: psql

# disable user
#    ALTER USER root NOLOGIN;
# enable user
#    ALTER USER root LOGIN;
