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

vim.keymap.set("v", "<D-Down>", '"+y', { noremap = true })

-- Delete key deletes the Visual selection, same as "d"
vim.keymap.set("v", "<BS>", "d", { noremap = true })
vim.keymap.set("v", "<Del>", "d", { noremap = true })

-- Control+Left/Right and Cmd+Left/Right both jump to start/end of line (your
-- pane-switching shortcut is Cmd+Shift+Arrow, a different combo, untouched)
-- (Neovim decodes iTerm2's 1;5D/1;5C to <C-Left>/<C-Right>, and 1;9D/1;9C to
-- <D-Left>/<D-Right>, on its own -- modifier 5 = Ctrl, 9 = Cmd, both standard
-- for arrow keys, unlike the CSI-u letter-key case above)
vim.keymap.set("n", "<C-Left>", "^", { noremap = true })
vim.keymap.set("n", "<C-Right>", "$", { noremap = true })
vim.keymap.set("v", "<C-Left>", "^", { noremap = true })
vim.keymap.set("v", "<C-Right>", "$", { noremap = true })
vim.keymap.set("i", "<C-Left>", "<C-o>^", { noremap = true })
vim.keymap.set("i", "<C-Right>", "<C-o>$", { noremap = true })

vim.keymap.set("n", "<D-Left>", "^", { noremap = true })
vim.keymap.set("n", "<D-Right>", "$", { noremap = true })
vim.keymap.set("v", "<D-Left>", "^", { noremap = true })
vim.keymap.set("v", "<D-Right>", "$", { noremap = true })
vim.keymap.set("i", "<D-Left>", "<C-o>^", { noremap = true })
vim.keymap.set("i", "<D-Right>", "<C-o>$", { noremap = true })

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
