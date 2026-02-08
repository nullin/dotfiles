{
  description = "nix-darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .
    darwinConfigurations."CW-JTXR767KJ5-L" = nix-darwin.lib.darwinSystem {
      modules = [
        ./configuration.nix
        {
          users.users.nmakar = {
            name = "nmakar";
            home = "/Users/nmakar";
          };
        }
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
