local curl  = require "plenary.curl"
local Job   = require "plenary.job"
local utils = require('rfc.utils')

local M     = {}

---@param query string
---@return RFC[]
function M:run_search(query)
    local res = curl.get("https://datatracker.ietf.org/api/v1/doc/document/?title__contains=" ..
        query:gsub("%s", "%%20") .. "&type=rfc")
    local json = vim.fn.json_decode(res.body).objects

    if next(json) == nil then
        error("No RFC found with that title")
    end

    return json
end

---@param rfc_id number
function M:get_rfc_text(rfc_id, callback)
    local test = Job:new({
        command = "curl",
        args = {
            "https://www.rfc-editor.org/rfc/rfc" .. rfc_id .. ".txt"
        },
        on_exit = function(j, return_val)
            local raw = j:result()
            vim.schedule(function()
                callback(utils:split_on_newline(table.concat(raw, "\n")))
            end)
        end,
    }):start()

    -- local resp = curl.get("https://www.rfc-editor.org/rfc/rfc" .. rfc_id .. ".txt")
    -- return utils:split_on_newline(resp.body)
end

return M
