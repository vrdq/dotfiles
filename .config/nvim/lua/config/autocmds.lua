-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local class_decompiler = vim.api.nvim_create_augroup("class_decompiler", { clear = true })

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = class_decompiler,
  pattern = "*.class",
  desc = "Open Java class files as CFR-decompiled source",
  callback = function(event)
    local class_file = vim.api.nvim_buf_get_name(event.buf)
    local result = vim.system({ "cfr", class_file, "--silent", "true" }, { text = true }):wait()

    if result.code ~= 0 then
      local message = vim.trim(result.stderr or "")
      vim.notify(message ~= "" and message or "CFR could not decompile this class file", vim.log.levels.ERROR)
      return
    end

    local source = vim.split(result.stdout or "", "\n", { plain = true })
    if source[#source] == "" then
      table.remove(source)
    end

    vim.bo[event.buf].modifiable = true
    vim.api.nvim_buf_set_lines(event.buf, 0, -1, false, source)
    vim.bo[event.buf].filetype = "java"
    vim.bo[event.buf].buftype = "nofile"
    vim.bo[event.buf].bufhidden = "wipe"
    vim.bo[event.buf].swapfile = false
    vim.bo[event.buf].modified = false
    vim.bo[event.buf].modifiable = false
    vim.bo[event.buf].readonly = true
  end,
})
