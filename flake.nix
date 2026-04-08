{
  description = "My NixOS config";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    systems.url = "github:nix-systems/default-linux";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colorizer.url = "github:nutsalhan87/nix-colorizer";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandex-browser = {
      url = "github:chek1337/yandex-browser.nix/feat/extensions-support";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zapret-discord-youtube = {
      url = "github:kartavkun/zapret-discord-youtube";
    };
    lazyvim-nix = {
      url = "github:pfassina/lazyvim-nix";
    };
    nixpkgs-nvim-0_11_6 = {
      url = "github:NixOS/nixpkgs/73a57bd3fe25d96c42311ae567e86ca542e62329";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-firefox-addons.url = "github:OsiPog/nix-firefox-addons";

    kitty-session = {
      url = "github:mad01/kitty-session/5e975c0dd2ea6fd915c9d89ff13318ec162621bc";
      flake = false;
    };
    kitty-zoxide-sessions = {
      url = "github:seankay/kitty-zoxide-sessions/d0908f2262ac3687aeb6313962c4667187aa3213";
      flake = false;
    };
    soundscope = {
      url = "github:bananaofhappiness/soundscope";
      flake = false;
    };
    pttkey = {
      url = "github:Wuild/pttkey/6bd2dfd7afe9c9a0fbf85459bf56c1244b9747b9";
      flake = false;
    };
    # niri fork implementing window pinning (https://github.com/niri-wm/niri/pull/3205)
    niri-pinned = {
      url = "github:my4ng/niri/bfea5ee499684fd1eb651b00d08915827a359261";
      flake = false;
    };
    push2talk = {
      url = "github:cyrinux/push2talk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-less-685 = {
      url = "github:NixOS/nixpkgs/a1bab9e494f5f4939442a57a58d0449a109593fe";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
