{
  description = "My NixOS config";

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree ./modules)
        (inputs.import-tree ./packages)
        ./nixvim
      ];
    };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-26.05";
    # Отдельный пин под nixGL, см. ниже почему он застрял на 25.11.
    nixpkgs-nixgl.url = "nixpkgs/nixos-25.11";

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
      # Upstream: the notification-invoke-latest IPC command (Mod+N raises the
      # source app of the latest notification) has been merged, so we track it
      # directly instead of the chek1337 fork.
      url = "github:noctalia-dev/noctalia";
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
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zapret-discord-youtube = {
      url = "github:kartavkun/zapret-discord-youtube";
    };
    nixvim.url = "github:nix-community/nixvim";
    # nixpkgs-nvim-0_11_6 = {
    #   url = "github:NixOS/nixpkgs/73a57bd3fe25d96c42311ae567e86ca542e62329";
    # };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-firefox-addons.url = "github:OsiPog/nix-firefox-addons";

    # nixGL: GPU-обёртка для Nix-GL-приложений на не-NixOS машинах. Нужна
    # standalone-пакетам kitty (Mesa) и kitty-nvidia, чтобы те подхватывали
    # драйвер хоста (Ubuntu и т.п.), а не «мёртвый» libGL из /nix/store.
    # NB: nixpkgs follows на ОТДЕЛЬНЫЙ пин nixpkgs-nixgl (25.11), а не на общий
    # nixpkgs-stable: nixGL собирает nvidia-либы через старый интерфейс
    # nvidia_x11 (override { kernel = null; }). В 26.05 этот аргумент убрали →
    # eval-ошибка `unexpected argument 'kernel'`, поэтому держим nixGL на 25.11,
    # где он ещё есть. Когда nixGL перейдёт на новый интерфейс — можно вернуть
    # follows на nixpkgs-stable и убрать отдельный инпут.
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs-nixgl";
    };

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
    # niri-pinned = {
    #   url = "github:my4ng/niri/bfea5ee499684fd1eb651b00d08915827a359261";
    #   flake = false;
    # };
    niri-float-sticky = {
      url = "github:probeldev/niri-float-sticky";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    push2talk = {
      url = "github:cyrinux/push2talk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-less-685 = {
      url = "github:NixOS/nixpkgs/a1bab9e494f5f4939442a57a58d0449a109593fe";
    };
    # Пин yazi на 26.1.22: в 26.5.6 Lua-движок стал трактовать переменную
    # цикла `for` как const, из-за чего падал плагин whoosh
    # ("attempt to assign to const variable 'token'").
    nixpkgs-yazi = {
      url = "github:NixOS/nixpkgs/549bd84d6279f9852cae6225e372cc67fb91a4c1";
    };
    # Пин satty на 0.20.1: в 0.21.x (коммит a14c1d16, «right click to clear
    # crop while editing») crop-инструмент получил отдельный editing-mode, из-за
    # которого Ctrl+C/right-click копируют весь экран, а не выделенную область,
    # пока crop не «зафиксирован». Регресс: Satty-org/Satty#560, #470.
    # Ревизия — родитель бампа satty 0.20.1 -> 0.21.1 в nixpkgs, там ещё 0.20.1.
    nixpkgs-satty = {
      url = "github:NixOS/nixpkgs/2f7793061c0dd564abb22061b930ea8f94d85126";
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
    hibiki.url = "github:linuxmobile/hibiki";
    elegant-grub2-themes = {
      url = "github:vinceliuice/Elegant-grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-floax-fork = {
      url = "github:chek1337/tmux-floax/feat/per-session-popup";
      flake = false;
    };
    ghgrab = {
      url = "github:abhixdd/ghgrab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
