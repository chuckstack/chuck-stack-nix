{ config, lib, pkgs, modulesPath, ... }:

let
  chuboeAuthKeyUrl = "https://raw.githubusercontent.com/cboecking/keys/refs/heads/main/id_rsa.pub";
  chuboeAuthKeys = pkgs.fetchurl {
    url = chuboeAuthKeyUrl;
    #sha256 = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  };
in
{
  users.users = {
    # Real sudo user that can log in
    chuboe2 = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ]; # Add any other groups as needed
      openssh.authorizedKeys.keys = [ chuboeAuthKeys ];
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

  # Create a group for the service user
  users.groups.serviceuser = {};

}
