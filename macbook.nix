{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ pkgs.autossh
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/src/dotfiles/macbook.nix
  environment.darwinConfig = "$HOME/src/dotfiles/macbook.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  # programs.zsh.enable = true;
  # programs.fish.enable = true;

  services.autossh.sessions = [ {
    name = "crunch";
    user = "jfelice";
    extraArguments = let key = ./ssh/files/id_rsa-macbook;
                     in " -i ${key}" +
                        " -L8820:localhost:8820" +
                        " -L8080:localhost:8080" +
                        " -L3447:localhost:3447" +
                        " -R/run/user/1000/plan9/srv/snarf:/Users/jfelice/.run/plan9/srv/snarf" +
                        " -L/Users/jfelice/.run/plan9/srv/plumb:/run/user/1000/plan9/srv/plumb" +
                        " -T -N crunch.eraserhead.net";
  } ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 1;
  nix.buildCores = 4;
}
