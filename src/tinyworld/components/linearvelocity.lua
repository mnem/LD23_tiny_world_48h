-- Module exports
local M = {}

local Class = {}
local Class_mt = { __index = Class }

function Class:setSpeed(dx, dy)
    self.dx = dx or self.dx
    self.dy = dy or self.dy
end

function M.factory()
    local instance = {
        dx = 0,
        dy = 0,
    }
    setmetatable( instance, Class_mt )

    return instance
end

return M
