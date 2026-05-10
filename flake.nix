{
  description = "OS as Code - NixOS & Home Manager";

  inputs = {
    # Nixpkgs (Versão Unstable para ter sempre os pacotes mais recentes)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager (Sincronizado com a branch do nixpkgs)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Adicionar o sops-nix aqui futuramente para os secrets
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {

    nixosConfigurations = {
      acer-aspire = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # Passa as variáveis (inputs) para todos os módulos
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/acer-aspire/default.nix

          # Integra o Home Manager diretamente na build do sistema
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            # Aponta para o ficheiro do utilizador
            home-manager.users.fajre = import ./users/fajre/home.nix;
          }
        ];
      };
    };
  };
}
