local M = {}

local dieSound = love.audio.newSource('assets/sounds/planet_die.wav', 'static')

M.components = {
    'position',
    'planet',
}

function M.processor(entities, lef)
    local pos, pln, tPos, tPln, rr, tRr, dx, dy, d
    for i, entity in ipairs(entities) do
        pos, pln = lef.entityComponents(entity, 'position', 'planet')
        rr = pln.radius * pln.radius
        for j=i+1, #entities do
            tPos, tPln = lef.entityComponents(entities[j], 'position', 'planet')
            dx = tPos.x - pos.x
            dy = tPos.y - pos.y
            d = dx * dx + dy * dy
            tRr = tPln.radius * tPln.radius
            if((rr + tRr) > d) then
                -- collide
                lef.destroyEntity(entity)
                lef.destroyEntity(entities[j])
                local fade, c = lef.addEntityComponents({}, 'tween', 'color', 'fadeout')
                c:setColor(255, 0, 0, 100)
                dieSound:play()
            end
        end
    end
end

return M
