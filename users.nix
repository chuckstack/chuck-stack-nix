{ config, lib, pkgs, modulesPath, ... }:

{
  users.users = {
    # Real user that can log in
    chuboe2 = {
      isNormalUser = true;
      #extraGroups = [ "wheel" "networkmanager" ]; # Add any other groups as needed
      #openssh.authorizedKeys.keys = [
      #  "ssh-rsa AAAAB3NzaC1yc2EAA... alice@example.com"
      #];
      # Add other user-specific configurations here
    };

    # Service user without login capabilities
    serviceuser = {
      isSystemUser = true;
      group = "serviceuser";
      description = "User for running services";

      # uncomment these lines if you need the user to have a home
      #home = "/var/lib/serviceuser";
      #createHome = true;
      #shell = pkgs.bashInteractive;  # or pkgs.nologin if you want to prevent interactive login

    };
  };
}
