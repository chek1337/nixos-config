{ stylixColors, ... }:
let
  c = stylixColors;
in
{
  #  vim.startPlugins = [ "alpha-nvim" ];
  #  vim.visuals.nvim-web-devicons.enable = true;
  #
  #  vim.pluginRC.alpha = ''
  #    local alpha     = require('alpha')
  #    local dashboard = require('alpha.themes.dashboard')
  #    local utils     = require('alpha.utils')
  #
  #    local function getGreeting(name)
  #      local t  = os.date('*t')
  #      local dt = os.date(' %Y-%m-%d-%A   %H:%M:%S ')
  #      local greetings = {
  #        [1] = '  Sleep well',
  #        [2] = '  Good morning',
  #        [3] = '  Good afternoon',
  #        [4] = '  Good evening',
  #        [5] = '󰖔  Good night',
  #      }
  #      local idx
  #      if t.hour == 23 or t.hour < 7 then idx = 1
  #      elseif t.hour < 12               then idx = 2
  #      elseif t.hour < 18               then idx = 3
  #      elseif t.hour < 21               then idx = 4
  #      else                                  idx = 5 end
  #      return dt .. '  ' .. greetings[idx] .. ', ' .. name
  #    end
  #
  #    local fill = vim.fn.winheight(0) - 43
  #    local logo = (fill >= 0 and [[
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #    ]] or "") ..
  #        [[
  #                                          
  #       ███████████           █████      ██
  #      ███████████             █████ 
  #      ████████████████ ███████████ ███   ███████
  #     ████████████████ ████████████ █████ ██████████████
  #    █████████████████████████████ █████ █████ ████ █████
  #  ██████████████████████████████████ █████ █████ ████ █████
  # ██████  ███ █████████████████ ████ █████ █████ ████ ██████
  # ██████   ██  ███████████████   ██ █████████████████
  #
  #      ]]
  #
  #    -- Stylix base16 highlight groups
  #    vim.api.nvim_set_hl(0, 'AlphaHdr_Orange', { fg = '#${c.base09}' })
  #    vim.api.nvim_set_hl(0, 'AlphaHdr_Yellow', { fg = '#${c.base0A}' })
  #    vim.api.nvim_set_hl(0, 'AlphaHdr_Shadow', { fg = '#${c.base01}' })
  #    vim.api.nvim_set_hl(0, 'AlphaHdr_Green',  { fg = '#${c.base0B}' })
  #    vim.api.nvim_set_hl(0, 'AlphaHdr_Cyan',   { fg = '#${c.base0C}' })
  #
  #    local header_hl = {}
  #
  #    if fill >= 0 then
  #      for _ = 1, fill do table.insert(header_hl, {}) end
  #    end
  #    table.insert(header_hl, {})                                          -- leading empty line
  #    table.insert(header_hl, { { 'AlphaHdr_Cyan',   46, 48 } })          -- space line
  #    table.insert(header_hl, {                                            -- ███████████ … ██
  #      { 'AlphaHdr_Orange', 7,  22 },
  #      { 'AlphaHdr_Green',  33, 40 },
  #      { 'AlphaHdr_Cyan',   40, 50 },
  #    })
  #    table.insert(header_hl, {                                            -- ███████████ … █████
  #      { 'AlphaHdr_Orange', 6,  21 },
  #      { 'AlphaHdr_Green',  33, 45 },
  #    })
  #    table.insert(header_hl, {                                            -- ████████████████ … ███████
  #      { 'AlphaHdr_Orange', 6,  19 },
  #      { 'AlphaHdr_Shadow', 19, 20 },
  #      { 'AlphaHdr_Yellow', 20, 35 },
  #      { 'AlphaHdr_Green',  35, 45 },
  #      { 'AlphaHdr_Cyan',   45, 90 },
  #    })
  #    table.insert(header_hl, {                                            -- ████████████████ … ██████████████
  #      { 'AlphaHdr_Orange', 5,  18 },
  #      { 'AlphaHdr_Yellow', 18, 36 },
  #      { 'AlphaHdr_Green',  36, 45 },
  #      { 'AlphaHdr_Cyan',   45, 90 },
  #    })
  #    table.insert(header_hl, {                                            -- █████████████████████████████ …
  #      { 'AlphaHdr_Orange', 4,  17 },
  #      { 'AlphaHdr_Yellow', 17, 24 },
  #      { 'AlphaHdr_Shadow', 24, 28 },
  #      { 'AlphaHdr_Yellow', 28, 37 },
  #      { 'AlphaHdr_Green',  37, 46 },
  #      { 'AlphaHdr_Cyan',   46, 90 },
  #    })
  #    table.insert(header_hl, {                                            -- ██████████████████████████████████ …
  #      { 'AlphaHdr_Orange', 2,  17 },
  #      { 'AlphaHdr_Yellow', 17, 38 },
  #      { 'AlphaHdr_Green',  38, 45 },
  #      { 'AlphaHdr_Cyan',   46, 90 },
  #    })
  #    table.insert(header_hl, {                                            -- ██████  ███ …
  #      { 'AlphaHdr_Orange', 1,  17 },
  #      { 'AlphaHdr_Yellow', 17, 38 },
  #      { 'AlphaHdr_Green',  38, 45 },
  #      { 'AlphaHdr_Cyan',   46, 90 },
  #    })
  #    table.insert(header_hl, {                                            -- ██████   ██ …
  #      { 'AlphaHdr_Shadow', 1,  37 },
  #      { 'AlphaHdr_Green',  37, 91 },
  #    })
  #
  #    local header_val = vim.split(logo, '\n')
  #    header_hl = utils.charhl_to_bytehl(header_hl, header_val, false)
  #
  #    dashboard.section.header.opts.hl = header_hl
  #    dashboard.section.header.val     = header_val
  #
  #    dashboard.section.buttons.val = {
  #      dashboard.button('n', '  New file',     ':ene <BAR> startinsert<CR>'),
  #      dashboard.button('f', '  Find file',    '<cmd>lua require("snacks").picker.files()<CR>'),
  #      dashboard.button('r', '󰄉  Recent files', '<cmd>lua require("snacks").picker.recent()<CR>'),
  #      dashboard.button('g', '  Live grep',    '<cmd>lua require("snacks").picker.grep()<CR>'),
  #      dashboard.button('s', '  Config',       '<cmd>lua require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })<CR>'),
  #      dashboard.button('q', '󰿅  Quit',         '<cmd>q<CR>'),
  #    }
  #    dashboard.section.buttons.opts.hl = 'AlphaHdr_Orange'
  #
  #    local userName = vim.fn.expand('$USER')
  #    dashboard.section.footer.val = { "", getGreeting(userName) }
  #
  #    local group = vim.api.nvim_create_augroup('AlphaDashboard', { clear = true })
  #    vim.api.nvim_create_autocmd('User', {
  #      group = group, pattern = 'AlphaReady',
  #      callback = function()
  #        vim.opt.showcmd = false
  #        vim.opt.ruler   = false
  #      end,
  #    })
  #    vim.api.nvim_create_autocmd('BufUnload', {
  #      group = group, pattern = '<buffer>',
  #      callback = function()
  #        vim.opt.showcmd = true
  #        vim.opt.ruler   = true
  #      end,
  #    })
  #
  #    dashboard.opts.opts.noautocmd = true
  #    alpha.setup(dashboard.opts)
  #  '';
}
