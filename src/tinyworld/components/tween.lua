-- Module exports
local M = {}

local Class = {}
local Class_mt = { __index = Class }

function Class:setTween(component, key, from, to, time, delay, onFinish)
    self.from = from or self.from
    self.to = to or self.to
    self.component = component or self.component
    self.key = key or self.key
    self.time = time or self.time
    self.delay = delay or self.delay
    self.onFinish = onFinish or self.onFinish
end

function M.factory()
    local instance = {
        birth = love.timer.getMicroTime(),
        delay = 0,
        time = 0.5,
        from = 0,
        to = 0,
        component = nil,
        key = nil,
        onFinish = nil,
    }
    setmetatable( instance, Class_mt )

    return instance
end

return M
