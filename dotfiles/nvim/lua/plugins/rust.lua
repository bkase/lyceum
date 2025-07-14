return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            procMacro = {
              enable = true,
              attributes = {
                enable = true,
              },
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
              features = "all",
            },
          },
        },
      },
    },
  },
}