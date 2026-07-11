-- ~/.config/nvim/init.lua
-- Neovim config: minimal core + a small set of curated plugins (lazy.nvim).
-- Tuned for studying and coding (SQL, Python, Ruby, JS/TS).

-- Leader MUST be set before lazy.nvim loads any plugin keymaps.
vim.g.mapleader = " "            -- leader = spacebar
vim.g.maplocalleader = " "

----------------------------------------------------------------------
-- Core options
----------------------------------------------------------------------
local opt = vim.opt
opt.number = true                -- line numbers
opt.relativenumber = true        -- relative numbers (jump with 5j, 3k, ...)
opt.mouse = "a"                  -- mouse enabled
opt.clipboard = "unnamedplus"    -- use the system clipboard
opt.termguicolors = true         -- full color

-- Indentation
opt.expandtab = true             -- spaces instead of tabs
opt.shiftwidth = 2               -- 2 spaces per level (Ruby/SQL)
opt.tabstop = 2
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true             -- uppercase in query => case-sensitive
opt.incsearch = true             -- highlight while typing
opt.hlsearch = true

-- Quality of life
opt.wrap = false
opt.scrolloff = 6                -- keep 6 lines of margin while scrolling
opt.swapfile = false
opt.undofile = true              -- undo persists after closing the file
opt.signcolumn = "yes"           -- avoid layout shifts

-- Python uses 4 spaces by convention
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function() opt.shiftwidth = 4; opt.tabstop = 4 end,
})

----------------------------------------------------------------------
-- Plugin manager bootstrap (lazy.nvim)
----------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

----------------------------------------------------------------------
-- Plugins
----------------------------------------------------------------------
require("lazy").setup({
  -- Colorscheme (load first, high priority so UI paints with the theme)
  {
    "tiagovla/tokyodark.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_background = false,
      gamma = 1.0,
    },
    config = function(_, opts)
      require("tokyodark").setup(opts)
      vim.cmd.colorscheme("tokyodark")
    end,
  },

  -- 1) File explorer (NERDTree) with icons: <leader>e toggles it open/closed
  {
    "preservim/nerdtree",
    cmd = { "NERDTree", "NERDTreeToggle", "NERDTreeFind" },
    dependencies = {
      "ryanoasis/vim-devicons",                 -- file-type glyphs (needs a Nerd Font)
      "tiagofumo/vim-nerdtree-syntax-highlight", -- colored icons by extension
    },
    keys = {
      { "<leader>e", "<cmd>NERDTreeToggle<CR>", desc = "Explorador de archivos (abrir/cerrar)" },
    },
    init = function()
      vim.g.NERDTreeShowHidden = 1
      vim.g.NERDTreeMinimalUI = 1
      vim.g.NERDTreeWinSize = 32
      vim.g.webdevicons_enable_nerdtree = 1
      vim.g.NERDTreeGitStatusUseNerdFonts = 1
    end,
  },

  -- 2) Fuzzy finder (Telescope): jump around code fast
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Telescope",
    keys = {
      { "<leader>f", "<cmd>Telescope find_files<CR>",                 desc = "Buscar archivos por nombre" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>",  desc = "Buscar texto en el archivo actual" },
      { "<leader>g", "<cmd>Telescope live_grep<CR>",                  desc = "Buscar texto en todos los archivos" },
      { "<leader>b", "<cmd>Telescope buffers<CR>",                    desc = "Cambiar entre archivos abiertos" },
      { "<leader>o", "<cmd>Telescope oldfiles<CR>",                   desc = "Archivos recientes" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "%.git/", "node_modules/", "%.lock" },
        },
      })
    end,
  },

  -- 3) Markdown rendering (README looks professional): <leader>r toggles format/raw
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {
      heading = { sign = false },
      code = { sign = false, width = "block", left_pad = 1, right_pad = 1 },
    },
  },

  -- 4) which-key: the popup menu that appears when you press <leader>
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
    },
  },

  -- 5) Flash: jump anywhere on screen by typing a label
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,             desc = "Saltar a cualquier texto en pantalla" },
      { "<leader>s",                   function() require("flash").jump() end,             desc = "Saltar entre palabras (a cualquier texto)" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,       desc = "Saltar y seleccionar bloque de código" },
      { "r", mode = "o",               function() require("flash").remote() end,           desc = "Flash remoto (operador)" },
      { "R", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Búsqueda con Treesitter" },
    },
  },

  -- Treesitter: better syntax highlighting + parsers for render-markdown.
  -- Uses the `main` branch (the rewrite) — required for Neovim 0.12+.
  -- The old `master` branch is frozen and crashes on 0.12 (injection predicates).
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Async, no-op when already installed. Parsers + queries land in stdpath/site.
      require("nvim-treesitter").install({
        "markdown", "markdown_inline", "lua", "vim", "vimdoc",
        "python", "ruby", "sql", "javascript", "typescript", "json", "bash",
      })
      -- Highlighting is enabled per-buffer (main branch dropped the module API).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function() pcall(vim.treesitter.start) end,
      })

      -- Compat shim: Telescope 0.1.x calls the old nvim-treesitter (`master`)
      -- API that the `main` branch removed. Provide just what Telescope uses,
      -- WITHOUT adding real keys to the parsers data table (it is iterated with
      -- vim.tbl_keys by get_available). Must run before Telescope loads, since
      -- its previewer captures `nvim-treesitter.configs` at module-load time.
      local ok, parsers = pcall(require, "nvim-treesitter.parsers")
      if ok and type(parsers) == "table" then
        local mt = getmetatable(parsers) or {}
        local orig = mt.__index
        mt.__index = function(t, k)
          if k == "ft_to_lang" then
            return function(ft) return vim.treesitter.language.get_lang(ft) or ft end
          elseif k == "get_parser" then
            return function(bufnr, lang) return vim.treesitter.get_parser(bufnr, lang) end
          end
          if type(orig) == "function" then return orig(t, k) end
          if type(orig) == "table" then return orig[k] end
          return nil
        end
        setmetatable(parsers, mt)
      end
      package.loaded["nvim-treesitter.configs"] = package.loaded["nvim-treesitter.configs"] or {
        is_enabled = function(_, lang)
          return type(lang) == "string"
            and #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) > 0
        end,
        get_module = function() return { additional_vim_regex_highlighting = false } end,
      }
    end,
  },
}, {
  ui = { border = "rounded" },
  change_detection = { notify = false },
})

----------------------------------------------------------------------
-- Keymaps (core)
----------------------------------------------------------------------
local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>", { desc = "Guardar archivo actual" })
map("n", "<leader>q", ":q<CR>", { desc = "Cerrar ventana / salir" })
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Quitar resaltado de búsqueda" })
map("i", "jk", "<Esc>", { desc = "Salir del modo insertar" })

-- <leader>r toggles markdown rendering only inside markdown buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "<leader>r", "<cmd>RenderMarkdown toggle<CR>",
      { buffer = args.buf, desc = "Markdown: ver con/sin formato" })
  end,
})

-- Inside NERDTree, `s` is taken (open split); guarantee Flash on <leader>s there too
vim.api.nvim_create_autocmd("FileType", {
  pattern = "nerdtree",
  callback = function(args)
    vim.keymap.set("n", "<leader>s", function() require("flash").jump() end,
      { buffer = args.buf, desc = "Saltar entre palabras (a cualquier texto)" })
  end,
})
