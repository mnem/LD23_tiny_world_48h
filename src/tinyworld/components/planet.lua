-- Module exports
local M = {}

local Class = {}
local Class_mt = { __index = Class }

function Class:setRadius(r)
    local rMinus2 = r - 2
    self.radius = r
    self.lats = {-rMinus2, -rMinus2/2, 0, rMinus2/2, rMinus2}
    self.longs = {-rMinus2, -rMinus2/2, 0, rMinus2/2, rMinus2}
end

function M.factory()
    local instance = {
        radius = 0,
        lats = {},
        longs = {},
        vrx = 0,
        vry = 0,
    }
    setmetatable( instance, Class_mt )

    instance:setRadius(10)

    return instance
end

return M
