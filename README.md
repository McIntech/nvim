# nvim

Minimal Neovim config: single `init.lua` + curated plugins via [lazy.nvim](https://github.com/folke/lazy.nvim). Tuned for studying and coding (SQL, Python, Ruby, JS/TS).

**Plugins:** tokyodark (theme) · NERDTree (explorer) · Telescope (fuzzy finder) · render-markdown · which-key · Flash (motions) · nvim-treesitter (`main` branch).

## Requirements

- Neovim **0.12+** (the treesitter `main` branch requires it)
- `git`
- A C compiler for treesitter parsers (macOS: `xcode-select --install`)
- [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter) (`brew install tree-sitter-cli`)
- [ripgrep](https://github.com/BurntSushi/ripgrep) for Telescope live grep (`brew install ripgrep`)
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal for icons

## Install

```bash
git clone https://github.com/McIntech/nvim ~/.config/nvim
nvim
```

First launch bootstraps lazy.nvim, installs all plugins, and downloads/compiles the treesitter parsers automatically. Wait for the installers to finish, then restart.

To pin plugins to the exact commits in `lazy-lock.json`:

```vim
:Lazy restore
```

Verify the setup with `:checkhealth`.

## Key bindings

Leader is `<Space>`. Press it and which-key shows every mapping. Highlights:

| Key         | Action                       |
| ----------- | ---------------------------- |
| `<leader>e` | Toggle file explorer         |
| `<leader>f` | Find files                   |
| `<leader>g` | Live grep                    |
| `<leader>/` | Fuzzy find in current buffer |
| `<leader>b` | Switch buffers               |
| `s`         | Flash jump to any text       |
| `<leader>r` | Toggle markdown rendering    |
| `jk`        | Exit insert mode             |
