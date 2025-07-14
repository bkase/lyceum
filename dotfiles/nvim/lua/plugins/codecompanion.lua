return {
  "olimorris/codecompanion.nvim",
  config = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = (function()
      local function create_local(model_name)
        return function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = { url = "http://localhost:1234" },
            schema = {
              model = { default = model_name },
            },
          })
        end
      end

      return {
        qwq32 = create_local("qwq-32b@4bit"),
        qwen25coder = create_local("qwen2.5-coder-32b-instruct"),
      }
    end)(),
    strategies = {
      chat = {
        adapter = "qwen25coder",
      },
      inline = {
        adapter = "qwen25coder",
      },
    },
  },
}
