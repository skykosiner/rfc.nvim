local curl          = require "plenary.curl"
local entry_display = require("telescope.pickers.entry_display")
local conf          = require("telescope.config").values
local previewers    = require('telescope.previewers')
local actions       = require('telescope.actions')
local action_state  = require('telescope.actions.state')

local M             = {}

---@class RFC
---@field abstract string
---@field pages number
---@field rfc_number number
---@field words number
---@field title string

---@param query string
---@return RFC[]
local function run_search(query)
    local res = curl.get("https://datatracker.ietf.org/api/v1/doc/document/?title__contains=" ..
        query:gsub("%s", "%%20") .. "&type=rfc")
    return vim.fn.json_decode(res.body).objects
end

local function split_on_newline(input)
    local result = {}
    for line in input:gmatch("([^\n]+)") do
        table.insert(result, line)
    end
    return result
end

---@param rfc_id number
---@return string[]
local function get_rfc_text(rfc_id)
    local res = curl.get("https://www.rfc-editor.org/rfc/rfc" .. rfc_id .. ".txt")
    return split_on_newline(res.body)
end

---@param lines string[]
local function open_rfc_window(lines)
    local buf_id = vim.api.nvim_create_buf(false, true)
    local line_num = 0

    for _, line in ipairs(lines) do
        line = line:gsub("", " ")
        vim.api.nvim_buf_set_lines(buf_id, line_num, -1, true, { line })
        line_num = line_num + 1
    end

    vim.api.nvim_win_set_buf(0, buf_id)
end

function M:search_rfc(opts)
    opts = opts or {}
    local search = vim.fn.input("Enter keyword > ")
    local rfcs = run_search(search)

    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = 4 },
            { remaining = true },
        },
    })

    local entries = {}
    for i, value in ipairs(rfcs) do
        table.insert(entries, {
            value = value,
            ordinal = value.title,
            display = function()
                return displayer({
                    tostring(value.rfc_number or i),
                    value.title,
                })
            end,
        })
    end

    require("telescope.pickers").new(opts, {
        prompt_title = "RFCs: " .. search,
        finder = require("telescope.finders").new_table({
            results = entries,
            entry_maker = function(entry)
                return {
                    value = entry.value,
                    ordinal = entry.ordinal,
                    display = entry.display,
                }
            end,
        }),
        previewer = previewers.new_buffer_previewer({
            title = "RFC",
            define_preview = function(self, entry)
                local lines = get_rfc_text(entry.value.rfc_number)
                local cleaned_lines = {}

                for _, line in ipairs(lines) do
                    line = line:gsub("", " ")
                    table.insert(cleaned_lines, line)
                end

                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, true, cleaned_lines)
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                local lines = get_rfc_text(selection.rfc_number)
                open_rfc_window(lines)
            end)
            return true
        end,
    }):find()
end

return M
