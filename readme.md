# chuck-stack-nix
This repository is incomplete. It is the current reference for deploying servers with nix templates.

Go to the [chuck-stack](https://chuck-stack.org)

# Summary
This repository includes nix configurations that are tool/purpose specific for deployment in NixOS servers. 

Since a new NixOS has few tools installed by default, you can run the following to enter a shell with git and neovim installed:

```
nix-shell --packages git neovim
cd /etc/nixos/
git clone https://github.com/chuckstack/chuck-stack-nix.git
nvim configuration.nix #make below changes
exit
```

These nix configs are designed to be composable. As a result, you can add multiple configuration files to the same server. Here is an example where you want to run postgresql and nginx on the same server:

```
...
  imports =
    [
      # Include the default lxd configuration.
      "${modulesPath}/virtualisation/lxc-container.nix"
      # Include the container-specific autogenerated configuration.
      ./lxd.nix
      ./chuck-stack-nix/system.nix  # here
      ./chuck-stack-nix/postgresql.nix  # here
      ./chuck-stack-nix/nginx.nix  # here
    ];
...
```

To rebuild with the new configuration:
```
nixos-rebuild switch
```

# Details
- This repository is incomplete
- Missing nginx reverse proxy configuration
- Missing secrets management
