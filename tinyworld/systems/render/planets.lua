local spacedust = require 'tinyworld.systems.render.spacedust'

local M = {}

M.components = {
    'position',
    'planet',
    'color',
}

M.priority = 1100

local function drawPlanet(x, y, pln, c)
    local r, rOver2
    love.graphics.setColor(c.red, c.green, c.blue, c.alpha)
    love.graphics.circle('fill', x, y, pln.radius, 16)
    r = pln.radius
    rOver2 = r / 2
    love.graphics.setLine(1, "smooth")
    love.graphics.setColor(200, 200, 200, 25)
    for i, lat in ipairs(pln.lats) do
        love.graphics.line(
            x, y - r,
            x + lat, y - rOver2,
            x + lat, y + rOver2,
            x, y + r
            )
        lat = lat + pln.vrx
        if lat < -(r - 2) then lat = (r - 2) end
        if lat > (r - 2) then lat = -(r - 2) end
        pln.lats[i] = lat
    end
    for i, long in ipairs(pln.longs) do
        love.graphics.line(
            x - r, y,
            x - rOver2, y + long,
            x + rOver2, y + long,
            x + r, y
            )
        long = long - pln.vry
        if long < -(r - 2) then long = (r - 2) end
        if long > (r - 2) then long = -(r - 2) end
        pln.longs[i] = long
    end
end

function M.processor(entities, lef)
    love.graphics.setColorMode('replace')
    for i, entity in ipairs(entities) do
        local pos, pln, c = lef.entityComponents(entity, 'position', 'planet', 'color')
        drawPlanet(pos.x, pos.y, pln, c)
    end
end

return M
