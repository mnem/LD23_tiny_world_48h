local M = {}

local bornSound = love.audio.newSource('assets/sounds/planet_born.wav', 'static')
local accreteSound = love.audio.newSource('assets/sounds/accrete.wav', 'static')
accreteSound:setLooping(true)
accreteSound:setVolume(0.5)


M.components = {
    'position',
    'linearvelocity',
    'spacedust',
    'accrete',
}

local PLANET_RADIUS = 24 * 24
local INFLUENCE_RADIUS = 110 * 110
local MAX_S = 20
local ACCEL = 0.8
local PLANET_DUST_NEEDED = 50

M.bitsLeft = 0

local COLORS = {
    {103, 168, 244, 24},
    {174, 34, 24, 32},
    {96, 150, 44, 20},
    {118, 150, 146, 15},
}

local doAccretion = false

local function allowAccretion(allow)
    if allow ~= doAccretion then
        doAccretion = allow
        if doAccretion then
            if accreteSound:isPaused() then
                accreteSound:resume()
            else
                accreteSound:play()
            end
        else
            accreteSound:pause()
        end
    end
end

function love.mousepressed()
    allowAccretion(true)
end

function love.mousereleased()
    allowAccretion(false)
end

local function spawnPlanet(lef, close, x, y)
    local pos, pln, vel, c = lef.addEntityComponents({}, 'position', 'planet', 'linearvelocity', 'color')
    pos.x = x
    pos.y = y
    vel.dx = 5 * math.random() - 2.5
    vel.dy = 5 * math.random() - 2.5
    pln.vrx = vel.dx / 20
    pln.vry = -vel.dy / 20

    local pCol = COLORS[math.floor((#COLORS - 1) * math.random()) + 1]
    c:setColor(pCol[1], pCol[2], pCol[3])
    pln:setRadius(pCol[4])

    -- Let the planet eat all the dust
    for i, dust in ipairs(close) do
        lef.destroyEntity(dust)
    end

    local fade, c = lef.addEntityComponents({}, 'tween', 'color', 'fadeout')
    c:setColor(255,255,255, 100)
    bornSound:play()
end

function M.processor(entities, lef)
    M.bitsLeft = #entities
    local g, c
    if doAccretion then
        local close = {}
        local pos, vel
        local mx = love.mouse.getX()
        local my = love.mouse.getY()

        for i, entity in ipairs(entities) do
            pos, vel, sd, c = lef.entityComponents(entity, 'position', 'linearvelocity', 'spacedust', 'color')

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

                    g = 55 + 100 - ((d - PLANET_RADIUS) / (INFLUENCE_RADIUS - PLANET_RADIUS) * 100)
                    c:setColor(g, g, g)
                else
                    c:setColor(255, 255, 255)
                    table.insert(close, entity)
                end
            else
                c:setColor(55, 55, 55)
            end
        end

        if #close > PLANET_DUST_NEEDED then
            spawnPlanet(lef, close, mx, my)
            allowAccretion(false)
        end
    else
        for i, entity in ipairs(entities) do
            c = lef.entityComponents(entity, 'color')
            c:setColor(55, 55, 55)
        end
    end
end

return M
