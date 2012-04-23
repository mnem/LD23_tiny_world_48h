local M = {}

local dieSound = love.audio.newSource('assets/sounds/planet_die.wav', 'static')

M.planetsDestroy = 0

M.components = {
    'position',
    'planet',
}

function M.processor(entities, lef)
    local pos, pln, tPos, tPln, dx, dy, d
    for i, entity in ipairs(entities) do
        local iWasHit = false
        pos, pln = lef.entityComponents(entity, 'position', 'planet')
        for j=i+1, #entities do
            tPos, tPln = lef.entityComponents(entities[j], 'position', 'planet')
            dx = tPos.x - pos.x
            dy = tPos.y - pos.y
            d = math.sqrt(dx * dx + dy * dy)
            if d < (pln.radius + tPln.radius) then
                -- collide
                if not pln.indestructable then
                    lef.destroyEntity(entity)
                end
                if not tPln.indestructable then
                    lef.destroyEntity(entities[j])
                    M.planetsDestroy =  M.planetsDestroy + 1
                end
                iWasHit = true
                dieSound:stop()
                dieSound:rewind()
                dieSound:play()
            end
        end
        if iWasHit then
            if not pln.indestructable then
                M.planetsDestroy =  M.planetsDestroy + 1
            end

            local c, txPos, txt, tween = lef.addEntityComponents({}, 'color', 'position', 'uitext', 'tween')
            c:setColor(255, 0, 0)
            txPos.x = pos.x - txt.width / 2
            txPos.y = pos.y
            txt.align = 'center'
            txt.text = "Boom! "..math.floor(2000000 * math.random()).." dead!"
            tween:setTween('color', 'alpha', 255, 0, 1.0, 3, function(entity)
                lef.destroyEntity(entity)
            end)

            local c, pos, shp, tween = lef.addEntityComponents({}, 'color', 'position', 'shape', 'tween', 'ui')
            c:setColor(255,0,0)
            shp.params = {800, 600}
            tween:setTween('color', 'alpha', 100, 0, 0.5, 0, function(entity)
                lef.destroyEntity(entity)
            end)

            local c, txPos, txt, tween = lef.addEntityComponents({}, 'color', 'position', 'uitext', 'tween')
            c:setColor(255, 255, 255)
            txt.width = 500
            txPos.x = 400 - txt.width / 2
            txPos.y = 570
            txt.align = 'center'
            txt.text = "Whoops! Try to avoid planets colliding by creating them further apart."
            tween:setTween('color', 'alpha', 255, 0, 0.5, 5, function(entity)
                lef.destroyEntity(entity)
            end)
        end
    end

    local text, pos, c = lef.addEntityComponents("ui planets exist", 'uitext', 'position', 'color')
    text.text = #entities.." tiny worlds created."
    pos.x = 10
    pos.y = 30
    c:setColor(73, 185, 67)

    text, pos, c = lef.addEntityComponents("ui planets destroyed", 'uitext', 'position', 'color')
    text.text = M.planetsDestroy.." tiny worlds annihilated."
    pos.x = 10
    pos.y = 50
    c:setColor(200, 53, 40)
end

return M
