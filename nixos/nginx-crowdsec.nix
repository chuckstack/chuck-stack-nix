{ config, lib, pkgs, modulesPath, ... }:

{
  environment.systemPackages = with pkgs; [
    # jdk17_headless
    # maven
    crowdsec
  ];

  # Ref: https://nixos.wiki/wiki/ACME
  # Ref: https://nixos.org/manual/nixos/stable/index.html#module-security-acme
  # Note: the below will fail to get a cert as is; however, it allows you to use ssl
  # Use the following to create your first page
    # mkdir -p /var/www/blog/; echo "hello world" > /var/www/blog/index.html

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "chuck@chuboe.com";
  services.nginx = {
    enable = true;
    virtualHosts = {
      #"localhost" = {
      #  locations."/" = {
      #    proxyPass = "http://localhost:3000";
      #    #proxyWebsockets = true;
      #  };
      #};
      "blog.example.com" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "myblog.example.com" ];
        locations."/" = {
          proxyPass = "http://localhost:3000";
          #proxyWebsockets = true;
        };
      };
    };
  };

  # staging server used for testing
  security.acme.defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

  environment.shellAliases = {
    "j" = "javac"; # just an example of defining an alias within a specific config
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # CrowdSec configuration
  services.crowdsec = {
    enable = true;
    config = {
      api = {
        server = {
          listen_uri = "127.0.0.1:8080";
          profiles_path = "/etc/crowdsec/profiles.yaml";
        };
      };
    };
  };

  # CrowdSec Nginx bouncer
  services.crowdsec-nginx-bouncer = {
    enable = true;
    settings = {
      api_url = "http://127.0.0.1:8080/";
      #api_key = "YOUR_API_KEY_HERE"; # Replace with your actual API key
      ban_time = "1h";
      ban_time_increment = "1";
      ban_time_increment_max = "12h";
    };
  };

  # Update Nginx configuration to use CrowdSec
  services.nginx = {
    appendHttpConfig = ''
      load_module modules/ngx_http_crowdsec_module.so;
      crowdsec;
    '';
  };
}
