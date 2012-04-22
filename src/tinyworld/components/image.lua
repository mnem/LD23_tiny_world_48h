-- Module exports
local M = {}

function M.factory()
     return {
        image = nil,
        sx = 1,
        sy = 1,
        ox = 0,
        oy = 0,
        kx = 0,
        ky = 0,
        r  = 0,
        colorMode = 'replace',
    }
end

return M
