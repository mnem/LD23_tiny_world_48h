-- Module exports
local M = {}

local Class = {}
local Class_mt = { __index = Class }

function Class:setColor(r, g, b, a)
    self.red = r or self.red
    self.green = g or self.green
    self.blue = b or self.blue
    self.alpha = a or self.alpha
end

function Class:setGray(g, a)
    self.red = g or self.red
    self.green = g or self.red
    self.blue = g or self.red
    self.alpha = a or self.alpha
end

function M.factory()
    local instance = {
        red = 0,
        green = 0,
        blue = 0,
        alpha = 255,
    }
    setmetatable( instance, Class_mt )

    return instance
end

return M
