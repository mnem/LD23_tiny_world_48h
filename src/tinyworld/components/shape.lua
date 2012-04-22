-- Module exports
local M = {}

local Class = {}
local Class_mt = { __index = Class }

function M.factory()
    local instance = {
        type = 'rectangle',
        fill = true,
        line = false,
        params = {},
    }
    setmetatable( instance, Class_mt )

    return instance
end

return M
