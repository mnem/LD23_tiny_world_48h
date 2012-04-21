local M = {}

M.components = {
    'position',
    'linearvelocity',
    'accrete'
}

local PLANET_RADIUS = 24 * 24
local INFLUENCE_RADIUS = 80 * 80
local MAX_S = 10
local ACCEL = 0.5
local PLANET_DUST_NEEDED = 50

function M.processor(entities, lef)
    if love.mouse.isDown('l') then
        local close = {}
        local pos, vel
        local mx = love.mouse.getX()
        local my = love.mouse.getY()

        for i, entity in ipairs(entities) do
            pos, vel = lef.entityComponents(entity, 'position', 'linearvelocity')

            -- Work out the entities distance from the mouse
            x = pos.x - mx
            y = pos.y - my
            d = x * x + y * y
            if d < INFLUENCE_RADIUS then
                if d > PLANET_RADIUS then
                    -- Move towards the point
                    if pos.x > mx then
                        vel.dx = vel.dx - ACCEL
                        if vel.dx < -MAX_S then vel.dx = -MAX_S end
                    end
                    if pos.x < mx then
                        vel.dx = vel.dx + ACCEL
                        if vel.dx > MAX_S then vel.dx = MAX_S end
                    end
                    if pos.y > my then
                        vel.dy = vel.dy - ACCEL
                        if vel.dy < -MAX_S then vel.dy = -MAX_S end
                    end
                    if pos.y < my then
                        vel.dy = vel.dy + ACCEL
                        if vel.dy > MAX_S then vel.dy = MAX_S end
                    end
                else
                    table.insert(close, entity)
                end
            end
        end

        -- See if there is enough of any one type to form a plane
        local dusts = {}
        local sd
        for i, closeEntity in ipairs(close) do
            sd = lef.entityComponents(closeEntity, 'spacedust')
            dusts[sd.dustType] = dusts[sd.dustType] or 0
            dusts[sd.dustType] = dusts[sd.dustType] + 1
        end

        local winner, winnerCount
        for type, count in pairs(dusts) do
            if winner == nil or count > winnerCount then
                winner = type
                winnerCount = count
            end
        end

        if winnerCount ~= nil and winnerCount > PLANET_DUST_NEEDED then
            -- New planet!
            local pos, pln, vel = lef.addEntityComponents({}, 'position', 'planet', 'linearvelocity')
            pos.x = mx
            pos.y = my
            pln.planetType = winner
            vel.dx = 5 * math.random() - 2.5
            vel.dy = 5 * math.random() - 2.5

            -- Let the planet eat all the dust
            for i, dust in ipairs(close) do
                lef.destroyEntity(dust)
            end
        end
    end
end

return M
