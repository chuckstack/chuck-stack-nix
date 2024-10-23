{ config, lib, pkgs, ... }:

{
  services.fail2ban = {
    enable = true;
    jails = {
      nginx-botsearch = ''
        enabled  = true
        port     = http,https
        filter   = nginx-botsearch
        logpath  = /var/log/nginx/access.log
        maxretry = 2
      '';
      nginx-http-auth = ''
        enabled  = true
        port     = http,https
        filter   = nginx-http-auth
        logpath  = /var/log/nginx/error.log
        maxretry = 3
      '';
    };
  };
}
