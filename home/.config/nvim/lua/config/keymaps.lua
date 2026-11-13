-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Auto-close pairs: type the opener, get both, cursor lands in the middle
local pairs_map = {
	["<>"] = "<><Left>",
	["()"] = "()<Left>",
	["{}"] = "{}<Left>",
	["[]"] = "[]<Left>",
	['""'] = '""<Left>',
	["''"] = "''<Left>",
	["``"] = "``<Left>",
	["**"] = "**<Left>",
	["****"] = "****<Left><Left>",
	["::"] = "::<Left>",
	["```"] = "```<CR><CR>```<Up>",
}
for lhs, rhs in pairs(pairs_map) do
	vim.keymap.set("i", lhs, rhs, { noremap = true })
end

-- Cmd+Shift+H/L in insert mode jump to start/end of line (iTerm sends these escape codes)
vim.keymap.set("i", "<Esc>[1;2H", "<C-o>^", { noremap = true })
vim.keymap.set("i", "<Esc>[1;2L", "<C-o>$", { noremap = true })

-- $, ^, {, } disabled as direct keys, then reassigned below via noremap
-- (noremap means K/J/H/L use the ORIGINAL meaning of {/}/^/$, bypassing the Nop)
for _, key in ipairs({ "$", "^", "{", "}" }) do
	vim.keymap.set({ "n", "v", "o" }, key, "<Nop>")
end

vim.keymap.set({ "n", "v", "o" }, "K", "{", { noremap = true })
vim.keymap.set({ "n", "v", "o" }, "J", "}", { noremap = true })
vim.keymap.set({ "n", "v", "o" }, "H", "^", { noremap = true })
vim.keymap.set({ "n", "v", "o" }, "L", "$", { noremap = true })

-- Insert-mode arrow substitutes
vim.keymap.set("i", "<C-k>", "<Up>", { noremap = true })
vim.keymap.set("i", "<C-j>", "<Down>", { noremap = true })
vim.keymap.set("i", "<C-h>", "<Left>", { noremap = true })
vim.keymap.set("i", "<C-l>", "<Right>", { noremap = true })

-- Tab/Shift-Tab indent the current line (normal) or selection (visual)
vim.keymap.set("n", ">>", "<Nop>")
vim.keymap.set("n", "<<", "<Nop>")
vim.keymap.set("v", ">>", "<Nop>")
vim.keymap.set("v", "<<", "<Nop>")

vim.keymap.set("n", "<Tab>", ">>", { noremap = true })
vim.keymap.set("n", "<S-Tab>", "<<", { noremap = true })
vim.keymap.set("v", "<Tab>", ">><Esc>gv", { noremap = true })
vim.keymap.set("v", "<S-Tab>", "<<<Esc>gv", { noremap = true })

-- Helpers for the Mac-style selection shortcuts below. Using normal! through a
-- Lua function (rather than chaining mapped keys as rhs strings) keeps each
-- combo's behavior independent of mode and of the other mappings.
local function in_visual()
	local m = vim.fn.mode()
	return m == "v" or m == "V" or m == "\22"
end

-- extend(motion): start/continue a selection in the given direction
local function extend(motion)
	return function()
		if in_visual() then
			vim.cmd("normal! " .. motion)
		else
			vim.cmd("normal! v" .. motion)
		end
	end
end

-- insert_extend(motion): leave insert mode, then start a selection
local function insert_extend(motion)
	return function()
		vim.cmd("stopinsert")
		vim.cmd("normal! v" .. motion)
	end
end

-- collapse(motion): drop any active selection, then just move
local function collapse(motion)
	return function()
		vim.cmd("normal! \27" .. motion)
	end
end

local function select_all()
	if in_visual() then
		vim.cmd("normal! \27ggVG")
	else
		vim.cmd("normal! ggVG")
	end
end

-- Cmd+A = select all, Cmd+C = copy selection to system clipboard
--
-- Every custom raw escape sequence we tried for these got mangled before
-- reaching any mapping: CSI-u (<Esc>[97;9u) had its Cmd bit silently dropped
-- by Neovim's decoder (arrived as plain "a"/"c" -- "c" in Visual mode means
-- "change", which is why text was vanishing); SS3 (<Esc>Oa) got collapsed by
-- Neovim's generic "Esc+char = Meta+char" fallback into <M-O> followed by a
-- separate "a". The ONE format Neovim decodes reliably through this whole
-- setup is modified arrow keys (CSI 1;<modifier><letter>), confirmed working
-- for Shift/Option/Control/Cmd everywhere else in this file. So instead of
-- inventing a new sequence, iTerm2 sends Cmd+A as if it were Cmd+Up
-- (<Esc>[1;9A) and Cmd+C as if it were Cmd+Down (<Esc>[1;9B) -- unused
-- combos we're repurposing as reliable signal channels. See setup notes.
vim.keymap.set("n", "<D-Up>", select_all)
vim.keymap.set("v", "<D-Up>", select_all)
vim.keymap.set("i", "<D-Up>", function()
	vim.cmd("stopinsert")
	vim.cmd("normal! ggVG")
end)

vim.keymap.set("v", "<D-Down>", function()
	vim.cmd('normal! "+y')
	vim.cmd("startinsert")
end, { noremap = true })

-- After any paste (Cmd+V, via terminal bracketed paste -- not a Neovim
-- keymap, so it's hooked through vim.paste instead), drop back into Insert
-- mode so you can keep typing, Mac-editor style, matching Cmd+C above
local orig_paste = vim.paste
vim.paste = function(lines, phase)
	local ok = orig_paste(lines, phase)
	if phase == -1 or phase == 3 then
		vim.schedule(function()
			vim.cmd("startinsert")
		end)
	end
	return ok
end

-- Delete key deletes the Visual selection and drops back into insert mode,
-- same as "c" (change) -- matches Mac-style editors where selecting text
-- then pressing Backspace removes it and leaves you typing, rather than
-- "d" which would delete the selection but land in Normal mode
vim.keymap.set("v", "<BS>", "c", { noremap = true })
vim.keymap.set("v", "<Del>", "c", { noremap = true })

-- Typing a printable character while a Visual selection is active replaces
-- the selection with that character, Mac-style (select text, type to
-- overwrite). Each key runs "c<char>": delete the selection, enter Insert
-- mode, then type the char. noremap so the "c" + char feed through as raw
-- keys rather than being re-expanded by these same mappings.
-- Trade-off: this shadows Vim's native Visual-mode single-key commands on
-- every key it covers (d/y/p/u/~/r/x/s/o/O/I/A/v/0/$/...) in favor of
-- literal typing, matching how selection-then-type works everywhere else.
for byte = 32, 126 do
	local char = string.char(byte)
	vim.keymap.set("v", char, "c" .. char, { noremap = true })
end

-- Control+Left/Right jumps to start/end of line
-- (Neovim decodes iTerm2's 1;5D/1;5C to <C-Left>/<C-Right> on its own --
-- modifier 5 = Ctrl, unlike the CSI-u letter-key case above)
vim.keymap.set("n", "<C-Left>", "^", { noremap = true })
vim.keymap.set("n", "<C-Right>", "$", { noremap = true })
vim.keymap.set("v", "<C-Left>", "^", { noremap = true })
vim.keymap.set("v", "<C-Right>", "$", { noremap = true })
vim.keymap.set("i", "<C-Left>", "<C-o>^", { noremap = true })
vim.keymap.set("i", "<C-Right>", "<C-o>$", { noremap = true })

-- Cmd+Left/Right switches buffers (tabs), matching iTerm's Ctrl+Tab for
-- terminal tabs -- freed up since Ctrl+Arrow already covers start/end of line
vim.keymap.set("n", "<D-Left>", "<cmd>bprevious<cr>", { noremap = true })
vim.keymap.set("n", "<D-Right>", "<cmd>bnext<cr>", { noremap = true })
vim.keymap.set("i", "<D-Left>", "<C-o><cmd>bprevious<cr>", { noremap = true })
vim.keymap.set("i", "<D-Right>", "<C-o><cmd>bnext<cr>", { noremap = true })

-- Cmd+Backspace closes the current buffer (Cmd+W is already claimed by
-- macOS/iTerm, so it can't be used here); mirrors LazyVim's <leader>bd
vim.keymap.set("n", "<D-BS>", function()
	Snacks.bufdelete()
end, { noremap = true })
vim.keymap.set("i", "<D-BS>", function()
	vim.cmd("stopinsert")
	Snacks.bufdelete()
end, { noremap = true })

-- Control+Shift+Left/Right = select from cursor to start/end of line
-- (modifier 6 = Ctrl+Shift combined; Neovim decodes to <C-S-Left>/<C-S-Right>)
vim.keymap.set({ "n", "v" }, "<C-S-Left>", extend("^"))
vim.keymap.set({ "n", "v" }, "<C-S-Right>", extend("$"))
vim.keymap.set("i", "<C-S-Left>", insert_extend("^"))
vim.keymap.set("i", "<C-S-Right>", insert_extend("$"))

-- Option+Left/Right = move by word (plain, no selection)
-- (Neovim auto-decodes iTerm2's xterm Alt-arrow bytes into <M-Left>/<M-Right> itself,
-- so map the symbolic name rather than the raw escape sequence)
vim.keymap.set("n", "<M-Left>", "b", { noremap = true })
vim.keymap.set("n", "<M-Right>", "w", { noremap = true })
vim.keymap.set("i", "<M-Left>", "<C-o>b", { noremap = true })
vim.keymap.set("i", "<M-Right>", "<C-o>w", { noremap = true })
vim.keymap.set("v", "<M-Left>", collapse("b"))
vim.keymap.set("v", "<M-Right>", collapse("w"))

-- Shift+Arrow = extend selection by character/line
-- Shift+Option+Left/Right = extend selection by word
-- (Neovim decodes these to <S-Left>/<S-Right>/<S-Up>/<S-Down>/<M-S-Left>/<M-S-Right>
-- on its own; iTerm2 must send the matching xterm modifier codes, see setup notes)
vim.keymap.set({ "n", "v" }, "<S-Left>", extend("h"))
vim.keymap.set({ "n", "v" }, "<S-Right>", extend("l"))
vim.keymap.set({ "n", "v" }, "<S-Up>", extend("k"))
vim.keymap.set({ "n", "v" }, "<S-Down>", extend("j"))
vim.keymap.set({ "n", "v" }, "<M-S-Left>", extend("b"))
vim.keymap.set({ "n", "v" }, "<M-S-Right>", extend("w"))

vim.keymap.set("i", "<S-Left>", insert_extend("h"))
vim.keymap.set("i", "<S-Right>", insert_extend("l"))
vim.keymap.set("i", "<S-Up>", insert_extend("k"))
vim.keymap.set("i", "<S-Down>", insert_extend("j"))
vim.keymap.set("i", "<M-S-Left>", insert_extend("b"))
vim.keymap.set("i", "<M-S-Right>", insert_extend("w"))

-- Releasing Shift and pressing a plain arrow should drop the selection and just
-- move, like a GUI editor, instead of Visual mode staying active and extending it
vim.keymap.set("v", "<Left>", collapse("h"))
vim.keymap.set("v", "<Right>", collapse("l"))
vim.keymap.set("v", "<Up>", collapse("k"))
vim.keymap.set("v", "<Down>", collapse("j"))

-- Cmd+Z / Cmd+Shift+Z = undo/redo, Mac-style. iTerm2 can't send Cmd+Z
-- reliably (same CSI-u letter-key problem as Cmd+A/Cmd+C above), so it's
-- configured to send Cmd+Shift+Up/Down (<Esc>[1;10A / <Esc>[1;10B) instead --
-- free channels we're repurposing as signal for this, same trick as Cmd+A/C.
vim.keymap.set("n", "<D-S-Up>", "u", { noremap = true })
vim.keymap.set("n", "<D-S-Down>", "<C-r>", { noremap = true })
vim.keymap.set("i", "<D-S-Up>", function()
	vim.cmd("stopinsert")
	vim.cmd("normal! u")
end, { noremap = true })
vim.keymap.set("i", "<D-S-Down>", function()
	vim.cmd("stopinsert")
	vim.cmd("normal! \18")
end, { noremap = true })

-- Cmd+P = open the file finder (same picker as <leader>ff) from any mode,
-- VS Code Quick-Open style. Leader-based menus only fire in Normal mode by
-- design (leader is Space, which must stay a literal space in Insert), so
-- this uses the same Cmd-combo trick as Cmd+Z/Cmd+Shift+Z: iTerm2 can't send
-- Cmd+P directly (CSI-u letter-key problem again), so it's configured to
-- send Cmd+Shift+Left (<Esc>[1;10D) instead -- the one remaining free
-- channel of that type.
local function open_file_finder()
	if in_visual() then
		vim.cmd("normal! \27")
	else
		vim.cmd("stopinsert")
	end
	LazyVim.pick("files")()
end
vim.keymap.set({ "n", "v", "i" }, "<D-S-Left>", open_file_finder, { noremap = true })

-- Cmd+Shift+P = open the start Dashboard. Same trick again: iTerm2 sends
-- Cmd+Shift+Right (<Esc>[1;10C) in place of the real Cmd+Shift+P, the last
-- free channel of this type.
local function open_dashboard()
	if in_visual() then
		vim.cmd("normal! \27")
	else
		vim.cmd("stopinsert")
	end
	Snacks.dashboard()
end
vim.keymap.set({ "n", "v", "i" }, "<D-S-Right>", open_dashboard, { noremap = true })

-- Option+Up/Down = move line (or Visual selection) up/down, same as LazyVim's
-- built-in <A-j>/<A-k>, just on Mac-style Option+Arrow as well
vim.keymap.set("n", "<M-Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { noremap = true })
vim.keymap.set("n", "<M-Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { noremap = true })
vim.keymap.set("i", "<M-Down>", "<esc><cmd>m .+1<cr>==gi", { noremap = true })
vim.keymap.set("i", "<M-Up>", "<esc><cmd>m .-2<cr>==gi", { noremap = true })
vim.keymap.set("v", "<M-Down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { noremap = true })
vim.keymap.set("v", "<M-Up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { noremap = true })

-- Ctrl+T toggles a horizontal (bottom split, non-float) terminal from any mode
vim.keymap.set({ "n", "i", "t" }, "<C-t>", function()
	vim.cmd("stopinsert")
	vim.cmd("ToggleTerm direction=horizontal")
end, { noremap = true })
