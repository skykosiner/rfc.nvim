local entry_display = require("telescope.pickers.entry_display")
local conf          = require("telescope.config").values
local previewers    = require('telescope.previewers')
local actions       = require('telescope.actions')
local action_state  = require('telescope.actions.state')
local rfc_data      = require('rfc.rfc_data')
local utils         = require('rfc.utils')

local M             = {}

---@class RFC
---@field abstract string
---@field pages number
---@field rfc_number number
---@field words number
---@field title string

function M.search_rfc(opts)
    opts = opts or {}

    local query = vim.fn.input("Enter keyword > ")
    local rfcs = rfc_data:run_search(query)

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
        prompt_title = "RFCs: " .. query,
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
                rfc_data:get_rfc_text(entry.value.rfc_number, function(lines)
                    local cleaned_lines = {}

                    for _, line in ipairs(lines) do
                        line = line:gsub("", " ")
                        table.insert(cleaned_lines, line)
                    end

                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, true, cleaned_lines)
                end)
            end,
        }),
        sorter = conf.generic_sorter(opts),
        -- TODO: Add support for tabs, splits, and so on within telescope
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry().value
                rfc_data:get_rfc_text(selection.rfc_number, function(lines)
                    actions.close(prompt_bufnr)
                    utils:open_rfc_window(lines)
                    vim.api.nvim_buf_set_name(0, tostring(selection.rfc_number))
                end)
            end)
            return true
        end,
    }):find()
end

return M
