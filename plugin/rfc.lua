local hasTelescope = pcall(require, "telescope")

if not hasTelescope then
    error("rfc.nvim requires telescope.nvim")
    return
end

local hasPlenary = pcall(require, "plenary")

if not hasPlenary then
    error("rfc.nvim requires plenary.nvim")
    return
end

vim.api.nvim_create_user_command("RFC", function(_)
    require("rfc").search_rfc()
end, { nargs = "?" })
