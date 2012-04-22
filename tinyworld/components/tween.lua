-- Module exports
local M = {}

function M.factory()
     return {
        birth = love.timer.getMicroTime(),
        time = 0.5,
    }
end

return M
