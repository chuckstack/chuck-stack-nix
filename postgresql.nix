{ config, lib, pkgs, modulesPath, ... }:

{
services.postgresql = {
     settings = {
       listen_addresses = "*";
     };
     enable = true;
     enableTCPIP = true;
     authentication = pkgs.lib.mkOverride 10 ''
 local all       all     trust
 host all all      ::1/128      scram-sha-256
 host all postgres 127.0.0.1/32 scram-sha-256
     '';
   };
}
# TODO: update for unix sockets
