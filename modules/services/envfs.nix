{
  # envfs FUSE-маунтит /bin и /usr/bin поверх PATH, благодаря чему чужие скрипты
  # с захардкоженными шебангами (/bin/bash, /usr/bin/python и т.п.) работают на
  # NixOS. В частности от этого зависит v2rayN: его embedded-скрипты режима
  # системного proxy (proxy_set_linux_sh, kill_as_sudo_linux_sh) вызывают
  # /bin/bash напрямую.
  flake.modules.nixos.envfs = {
    services.envfs.enable = true;
  };
}
