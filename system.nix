{
  config, pkgs, ...
}:
{
  environment.systemPackages = with pkgs; [
    vim          # Command-line text editor
    git          # Version control system
    wget         # Utility to retrieve files from the web
    curl         # Command-line tool for transferring data with URLs
  ];

  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fi";

  services.ntp.enable = true;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  system.stateVersion = "24.05";
}

