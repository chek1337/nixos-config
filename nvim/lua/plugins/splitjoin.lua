return {
  "nvim-mini/mini.splitjoin",
  version = "*",
  keys = {
    { "gjj", desc = "Join" },
    { "gjs", desc = "Split" },
  },
  opts = {
    mappings = {
      toggle = "",
      join = "gjj",
      split = "gjs",
    },
  },
}
