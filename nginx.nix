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
      "blog.example.com" = {
        forceSSL = true;
        enableACME = true;
        # All serverAliases will be added as extra domain names on the certificate.
        serverAliases = [ "myblog.example.com" ];
        locations."/" = {
          root = "/var/www/blog";
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

}
