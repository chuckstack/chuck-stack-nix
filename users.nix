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
    };
  };

  # Create a group for the service user
  users.groups.serviceuser = {};
}
