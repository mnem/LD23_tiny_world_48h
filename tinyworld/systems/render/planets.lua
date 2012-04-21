local spacedust = require 'tinyworld.systems.render.spacedust'

local M = {}

M.components = {
    'position',
    'planet',
}

M.priority = 500

function M.processor(entities, lef)
    love.graphics.setColorMode('replace')
    local c
    for i, entity in ipairs(entities) do
        local pos, pln= lef.entityComponents(entity, 'position', 'planet')
        c = spacedust.COLORS[pln.planetType]
        love.graphics.setColor(c[1], c[2], c[3], c[4])
        love.graphics.circle('fill', pos.x, pos.y, 24, 16)
    end
end

return M
