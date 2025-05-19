local curl  = require "plenary.curl"
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
---@return string[]
function M:get_rfc_text(rfc_id)
    local resp = curl.get("https://www.rfc-editor.org/rfc/rfc" .. rfc_id .. ".txt")
    return utils:split_on_newline(resp.body)
end

return M
