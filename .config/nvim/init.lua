-- ~/.config/nvim/init.lua
-- Neovim 0.12+. 6 plugins. Helix-style goto / space menu / bracket navigation.

-- ─────────────────────────────── options ───────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number         = true      -- number + relativenumber = Helix line-number="relative"
o.relativenumber = true
o.cursorline     = true
o.winborder      = "rounded" -- ≈ popup-border = "all"
o.signcolumn     = "yes"
o.mouse          = "a"
o.undofile       = true
o.ignorecase     = true
o.smartcase      = true
o.inccommand     = "split"
o.splitright     = true
o.splitbelow     = true
o.expandtab      = true
o.shiftwidth     = 2
o.tabstop        = 2
o.wrap           = false
o.scrolloff      = 8
o.updatetime     = 250
o.timeoutlen     = 400
o.confirm        = true
o.completeopt    = "menuone,noselect,popup,fuzzy"

-- No clipboard=unnamedplus on purpose: stalls over SSH / on headless boxes.
-- Helix-style <space>y / <space>p below instead.

o.path:append("**")
o.wildmode = "longest:full,full"
if vim.fn.executable("rg") == 1 then
  o.grepprg = "rg --vimgrep --smart-case"
  o.grepformat = "%f:%l:%c:%m"
end

-- ────────────────────────── diagnostics ────────────────────────────────
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  virtual_text = {
    prefix = "●",
    severity = { min = vim.diagnostic.severity.INFO },  -- ≈ end-of-line-diagnostics
  },
  virtual_lines = { current_line = true },              -- ≈ inline-diagnostics.cursor-line
  float = { source = true },
})

-- ─────────────────── plugins (vim.pack, built in) ──────────────────────
-- :packupdate to pull, :packdel to remove.
-- Revisions pin into ~/.config/nvim/nvim-pack-lock.json — commit that file.

vim.pack.add({
  { src = "https://github.com/ellisonleao/gruvbox.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-mini/mini.nvim" },

  -- blink ships its prebuilt Rust matcher only on tagged releases, and vim.pack
  -- has no build hooks — pin a version or you'll need cargo. Check blink's
  -- README and bump this if it moved past 1.x.
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

require("gruvbox").setup({ contrast = "hard" })   -- = gruvbox_dark_hard
vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")

local fzf = require("fzf-lua")
fzf.setup({ winopts = { preview = { layout = "vertical" } } })

require("oil").setup({ view_options = { show_hidden = true } })

require("blink.cmp").setup({
  keymap = { preset = "default" },   -- <C-y> accept, <C-n>/<C-p> cycle, <C-space> docs
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  completion = { documentation = { auto_show = true, auto_show_delay_ms = 200 } },
  signature = { enabled = true },
})

require("mini.surround").setup()   -- sa / sd / sr
require("mini.ai").setup()         -- va) vif vaa ...
require("mini.pairs").setup()
require("mini.statusline").setup({ use_icons = false })

-- ═══════════════════════════ keymaps ═══════════════════════════════════
local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Normal mode" })

-- C-s needs `stty -ixon` in your shell rc, or flow control eats it.
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Write" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("t", "<Esc><Esc>", "<C-\\><C-n>")

-- ───────────────── space menu (Helix <space>) ──────────────────────────
map("n", "<leader>f", fzf.files,                    { desc = "File picker" })
map("n", "<leader>F", function()                      -- relative to current file
  fzf.files({ cwd = vim.fn.expand("%:p:h") })
end,                                                { desc = "Files (buffer dir)" })
map("n", "<leader>b", fzf.buffers,                  { desc = "Buffer picker" })
map("n", "<leader>j", fzf.jumps,                    { desc = "Jumplist picker" })
map("n", "<leader>s", fzf.lsp_document_symbols,     { desc = "Symbol picker" })
map("n", "<leader>S", fzf.lsp_live_workspace_symbols, { desc = "Workspace symbols" })
map("n", "<leader>d", fzf.diagnostics_document,     { desc = "Diagnostics" })
map("n", "<leader>D", fzf.diagnostics_workspace,    { desc = "Workspace diagnostics" })
map("n", "<leader>/", fzf.live_grep,                { desc = "Global search" })
map("n", "<leader>'", fzf.resume,                   { desc = "Last picker" })
map("n", "<leader>?", fzf.commands,                 { desc = "Command palette" })
map("n", "<leader>h", fzf.lsp_references,           { desc = "References" })

map("n", "<leader>a", vim.lsp.buf.code_action,      { desc = "Code action" })
map("n", "<leader>r", vim.lsp.buf.rename,           { desc = "Rename symbol" })
map("n", "<leader>k", vim.lsp.buf.hover,            { desc = "Hover docs" })

map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste before" })

map("n", "<leader>w", "<C-w>", { remap = true, desc = "Window mode" })

-- ───────────────── goto mode (Helix g) ─────────────────────────────────
-- These don't clash with anything and are free wins.
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto type definition" })
map("n", "gh", "^",                         { desc = "Goto line start" })
map("n", "gl", "$",                         { desc = "Goto line end" })
map("n", "gs", "_",                         { desc = "Goto first non-blank" })
map("n", "ga", "<C-^>",                     { desc = "Goto alternate file" })
map("n", "gt", "H",                         { desc = "Goto window top" })
map("n", "gb", "L",                         { desc = "Goto window bottom" })
map("n", "g.", "`.",                        { desc = "Goto last modification" })

-- gd works natively in 0.12. gD = declaration, matching Helix:
map("n", "gD", vim.lsp.buf.declaration,     { desc = "Goto declaration" })

-- ┌─────────────────────────────────────────────────────────────────────┐
-- │ CONFLICT ZONE — these shadow real Vim motions. Delete the block if  │
-- │ your muscle memory disagrees; everything above still works.         │
-- └─────────────────────────────────────────────────────────────────────┘

-- gr = references. This kills 0.12's gr* prefix (grn rename, gra code action,
-- grr references, gri implementation). Fine here, because the space menu
-- above covers all four Helix-style.
map("n", "gr", vim.lsp.buf.references,      { desc = "Goto references" })
map("n", "gi", vim.lsp.buf.implementation,  { desc = "Goto implementation" })

-- ge: Vim = end of previous word. Helix = last line of file.
map("n", "ge", "G",                         { desc = "Goto last line" })

-- gn: Vim = select next search match (works with . repeat — genuinely useful).
-- gp: Vim = paste and leave cursor after.
map("n", "gn", "<cmd>bnext<cr>",            { desc = "Next buffer" })
map("n", "gp", "<cmd>bprevious<cr>",        { desc = "Previous buffer" })

-- Helix has this on gc, but 0.12 uses gc for comments. Kept comments.
map("n", "gz", "M",                         { desc = "Goto window center" })

-- ───────────────── bracket navigation (Helix [ / ]) ────────────────────
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,  { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]D", function() vim.diagnostic.jump({ count = math.huge }) end,        { desc = "Last diagnostic" })
map("n", "[D", function() vim.diagnostic.jump({ count = -math.huge }) end,       { desc = "First diagnostic" })

-- ]f / [f: Vim's built-in ]m / [m (next/prev method start). Syntax-based, not
-- treesitter, so it's solid in C and Java and shakier elsewhere.
map("n", "]f", "]m", { remap = true, desc = "Next function" })
map("n", "[f", "[m", { remap = true, desc = "Prev function" })

map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Prev quickfix" })

-- Helix ]space / [space: blank line below / above without leaving normal mode.
map("n", "]<space>", "o<Esc>k", { desc = "Blank line below" })
map("n", "[<space>", "O<Esc>j", { desc = "Blank line above" })

-- ───────────────── misc ────────────────────────────────────────────────
map("n", "-", "<cmd>Oil<cr>", { desc = "Parent dir" })

map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<cr>gv=gv")
map("v", "K", ":m '<-2<cr>gv=gv")

-- Inlay hints off by default, toggle on demand.
map("n", "<leader>i", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- LSP formatting stays available even without conform.
map("n", "<leader>=", function() vim.lsp.buf.format() end, { desc = "Format" })

-- ────────────────────────────── autocmds ───────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if ft == "gitcommit" or ft == "gitrebase" then return end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ────────────────────────────── lsp ────────────────────────────────────
-- nvim-lspconfig is only a bag of default server configs that vim.lsp.enable
-- reads off the runtimepath. Nothing starts until you open a matching
-- filetype. Each name needs its binary on PATH or it fails silently.
vim.lsp.enable({
  "lua_ls",
  "clangd",   -- works on single .c files without compile_commands.json
  "jdtls",
})

vim.lsp.config("lua_ls", {
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

-- ─────────────────────────── treesitter ────────────────────────────────
-- Nothing to configure. Core ships parsers for lua, c, vim, vimdoc, query and
-- markdown and highlights them automatically. For other languages see
-- :h treesitter-parsers.
