{ config, lib, pkgs, modulesPath, ... }:

{
  environment.systemPackages = with pkgs; [
    # jdk17_headless
    # maven
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
        locations = {

	  # Root "/" path
	  "/" = {
          #  return = "404"; # Uncomment "/" if you wish to block the root url access - openapi/swagger
            proxyPass = "http://localhost:3000";
	  #  proxyWebsockets = true;
          };

	  # Allow access to any non-empty path - example: /some_table - use if root url is blocked above
          #"~ ^/(?!$).*" = {
          #  # This location block matches any non-empty path
          #  proxyPass = "http://localhost:3000";
          #};

	  # Allow access to a specific path - most strict option - use if root url is blocked above
          #locations."/stk_todo" = {
          #  proxyPass = "http://localhost:3000";
          #};

        };
      };
    };

    # Enable access and error logging
    appendHttpConfig = ''
      access_log /var/log/nginx/access.log;
      error_log /var/log/nginx/error.log;
    '';
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

}
