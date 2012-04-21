-- Module exports
local M = {}

function M.factory()
     return {
        dx = 0,
        dy = 0,
        setSpeed = function(self, dx, dy, dr)
            self.dx = dx
            self.dy = dy
        end,
    }
end

return M
