local M = {}

M.components = {
    'position',
    'linearvelocity',
    'accrete'
}

local PLANET_RADIUS = 24 * 24
local INFLUENCE_RADIUS = 110 * 110
local MAX_S = 20
local ACCEL = 0.8
local PLANET_DUST_NEEDED = 50

local function countCloseDust(lef, close)
    local dusts = {}
    local sd
    for i, closeEntity in ipairs(close) do
        sd = lef.entityComponents(closeEntity, 'spacedust')
        dusts[sd.dustType] = dusts[sd.dustType] or 0
        dusts[sd.dustType] = dusts[sd.dustType] + 1
    end

    local winner = nil
    local winnerCount = 0
    for type, count in pairs(dusts) do
        if winner == nil or count > winnerCount then
            winner = type
            winnerCount = count
        end
    end

    return winner, winnerCount
end

local function spawnPlanet(lef, winner, close, x, y)
    -- New planet!
    local pos, pln, vel = lef.addEntityComponents({}, 'position', 'planet', 'linearvelocity')
    pos.x = x
    pos.y = y
    pln.planetType = winner
    vel.dx = 5 * math.random() - 2.5
    vel.dy = 5 * math.random() - 2.5
    vel.vrx = -vel.dx / 20
    vel.vry = -vel.dy / 20

    -- Let the planet eat all the dust
    local trg, sd, sdpos
    for i, dust in ipairs(close) do
        trg, sd, sdpos = lef.addEntityComponents(dust, 'orbittarget', 'spacedust', 'position')
        if pln.planetType ~= sd.dustType then
            lef.removeEntityComponents(dust, 'accrete')
            trg.target = pos
            trg.radiusradius = 15 * 15
            sdpos.x = pos.x
            sdpos.y = pos.y
            sd.alpha = 80
        else
            lef.destroyEntity(dust)
        end
    end
end

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

        -- See if there is enough of any one type to form a planet
        local winner, winnerCount = countCloseDust(lef, close)
        if winnerCount > PLANET_DUST_NEEDED then
            spawnPlanet(lef, winner, close, mx, my)
        end
    end
end

return M
