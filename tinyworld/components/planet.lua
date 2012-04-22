-- Module exports
local M = {}

function M.factory()
     return {
        planetType = 1,
        lats = {-22, -11, 0, 11, 22},
        longs = {-22, -11, 0, 11, 22},
        vrx = 0.2,
        vry = 0.2,
    }
end

return M
