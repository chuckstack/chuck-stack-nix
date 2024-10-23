{ config, lib, pkgs, modulesPath, ... }:

{
  services.fail2ban = {
    enable = true;
    jails = {
      nginx-general = ''
        enabled  = true
        port     = http,https
        filter   = nginx-general
        logpath  = /var/log/nginx/access.log
        maxretry = 5
        bantime  = 1h
        findtime = 10m
      '';
    };
  };

  # Define a custom filter for Nginx
  environment.etc."fail2ban/filter.d/nginx-general.conf".text = ''
    [Definition]
    failregex = ^<HOST> - .* "(GET|POST|HEAD).*" (404|444|403|400) .*$
    ignoreregex =
  '';
}
