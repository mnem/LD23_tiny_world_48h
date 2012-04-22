local spacedust = require 'tinyworld.systems.render.spacedust'

local M = {}

M.components = {
    'position',
    'planet',
}

M.priority = 1100

function M.processor(entities, lef)
    love.graphics.setColorMode('replace')
    local c
    for i, entity in ipairs(entities) do
        local pos, pln = lef.entityComponents(entity, 'position', 'planet')
        c = spacedust.COLORS[pln.planetType]
        love.graphics.setColor(c[1], c[2], c[3], 200)
        love.graphics.circle('fill', pos.x, pos.y, 24, 16)

        love.graphics.setLine(1, "smooth")
        love.graphics.setColor(255, 255, 255, 25)
        for i, lat in ipairs(pln.lats) do
            love.graphics.line(
                pos.x, pos.y - 24,
                pos.x + lat, pos.y - 12,
                pos.x + lat, pos.y + 12,
                pos.x, pos.y + 24
                )
            lat = lat + pln.vrx
            if lat < -22 then lat = 22 end
            if lat > 22 then lat = -22 end
            pln.lats[i] = lat
        end
        for i, long in ipairs(pln.longs) do
            love.graphics.line(
                pos.x - 24, pos.y,
                pos.x - 12, pos.y + long,
                pos.x + 12, pos.y + long,
                pos.x + 24, pos.y
                )
            long = long - pln.vry
            if long < -22 then long = 22 end
            if long > 22 then long = -22 end
            pln.longs[i] = long
        end
    end
end

return M
