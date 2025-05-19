local utils = {}

function utils:split_on_newline(input)
    local result = {}
    for line in input:gmatch("([^\n]+)") do
        table.insert(result, line)
    end
    return result
end

---@param lines string[]
function utils:open_rfc_window(lines)
    local buf_id = vim.api.nvim_create_buf(false, true)
    local line_num = 0

    for _, line in ipairs(lines) do
        line = line:gsub("", " ")
        vim.api.nvim_buf_set_lines(buf_id, line_num, -1, true, { line })
        line_num = line_num + 1
    end

    vim.api.nvim_win_set_buf(0, buf_id)
end

return utils
