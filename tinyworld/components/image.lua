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
        red = 0,
        green = 0,
        blue = 0,
        alpha = 255,
        setColor = function(self, r, g, b, a)
                self.red = r or self.red
                self.green = g or self.green
                self.blue = b or self.blue
                self.alpha = a or self.alpha
        end,
    }
end

return M
