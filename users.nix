{
  config, pkgs, ...
}:
{
  users.users.laged = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7jC7BFaDF7lk8KGAITtjhyvcGec1RjWnHoNMxjJ0Q4 laged@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJdn2vPGZTEjYW82B82c39mllbjH/XFrXZyYwB+8zI4 laged@Mattis-MacBook-Air.local"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7jC7BFaDF7lk8KGAITtjhyvcGec1RjWnHoNMxjJ0Q4 laged@nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJdn2vPGZTEjYW82B82c39mllbjH/XFrXZyYwB+8zI4 laged@Mattis-MacBook-Air.local"
  ];

  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "laged";
}

