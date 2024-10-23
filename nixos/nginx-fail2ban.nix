{ config, lib, pkgs, modulesPath, ... }:

# Commands for testing and validating:
  # cat /var/log/nginx/access.log
  # systemctl status fail2ban.service
  # fail2ban-client status
  # fail2ban-client status nginx-general

{
  services.fail2ban = {
    enable = true;
    jails = {
      nginx-general = ''
        enabled  = true
        port     = http,https
        filter   = nginx-general
        logpath  = /var/log/nginx/access.log
        maxretry = 3
        bantime  = 12h
        pollinterval = 3s
        findtime = 1h
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
