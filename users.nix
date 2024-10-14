{ config, lib, pkgs, modulesPath, ... }:

let
  chuboeKeys = pkgs.fetchFromGitHub {
    owner = "cboecking";
    repo = "keys";
    rev = "main";  # or any other branch or commit hash
    sha256 = "";  # replace with actual hash
  };
  chuboeAuthKeys = "${chuboeKeys}/id_rsa.pub";
in
#let
#  chuboeAuthKeyUrl = "https://raw.githubusercontent.com/cboecking/keys/refs/heads/main/id_rsa.pub";
#  chuboeAuthKeys = pkgs.fetchurl {
#    url = chuboeAuthKeyUrl;
#    sha256 = "sha256-P6urHYR0fpoy+TF4xTzDdqf8ao894QEk1XQ/TbT0TLQ"; #note: an empty string removes the hash check - nix will complain
#  };
#in
{
  users.users = {
    # Real sudo user that can log in
    chuboe2 = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ]; # Add any other groups as needed
      openssh.authorizedKeys.keyFiles = [ chuboeAuthKeys ];

      # Add other user-specific configurations here
      packages = with pkgs; [
        #firefox
        #thunderbird
      ];
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
