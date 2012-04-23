local M = {}
local lef = require 'nah.lef'

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

M.bitsLeft = 0
M.planetsLeft = 0
M.planetsFormed = 0
M.PLANET_DUST_NEEDED = 50
M.gameOver = false

local COLORS = {
    {103, 168, 244, 24},
    {103, 168, 244, 24},
    {103, 168, 244, 24},
    {103, 168, 244, 24},
    {174, 34, 24, 32},
    {174, 34, 24, 32},
    {96, 150, 44, 20},
    {96, 150, 44, 20},
    {118, 150, 146, 15},
    {118, 150, 146, 15},
    {118, 150, 146, 15},
}

local doAccretion = false

local function allowAccretion(allow)
    if allow ~= doAccretion then
        doAccretion = allow
        if not doAccretion then
            lef.destroyEntity("accretion cur")
            lef.destroyEntity("accretion max")
        end
        -- if doAccretion then
        --     if accreteSound:isPaused() then
        --         accreteSound:resume()
        --     else
        --         accreteSound:play()
        --     end
        -- else
        --     accreteSound:pause()
        -- end
    end
end

function love.mousepressed()
    allowAccretion(true)
end

function love.mousereleased()
    allowAccretion(false)
end

local function spawnPlanet(lef, close, x, y, pCol, velx, vely, prx, pry, indestructable, name)
    local pos, pln, vel, c = lef.addEntityComponents(name or {}, 'position', 'planet', 'linearvelocity', 'color')
    pos.x = x
    pos.y = y
    vel.dx = velx or 5 * math.random() - 2.5
    vel.dy = vely or 5 * math.random() - 2.5
    pln.vrx = prx or vel.dx / 20
    pln.vry = pry or -vel.dy / 20
    pln.indestructable = indestructable or false

    c:setColor(pCol[1], pCol[2], pCol[3], 200)
    pln:setRadius(pCol[4])

    -- Let the planet eat all the dust
    for i, dust in ipairs(close) do
        lef.destroyEntity(dust)
    end

    local c, pos, shp, tween = lef.addEntityComponents({}, 'color', 'position', 'shape', 'tween', 'ui')
    c:setColor(255,255,255)
    shp.params = {800, 600}
    tween:setTween('color', 'alpha', 100, 0, 0.5, 0, function(entity)
        lef.destroyEntity(entity)
    end)

    bornSound:stop()
    bornSound:rewind()
    bornSound:play()

    M.planetsFormed = M.planetsFormed + 1

    lef.destroyEntity("ui planet forming help")
end

function M.processor(entities, lef)
    M.bitsLeft = #entities
    M.planetsLeft = math.floor(M.bitsLeft / M.PLANET_DUST_NEEDED)
    local text, pos, c = lef.addEntityComponents("ui planets left", 'uitext', 'position', 'color')
    text.text = M.planetsLeft.." tiny worlds remaining to be formed."
    pos.x = 10
    pos.y = 10
    c:setColor(200, 183, 85)

    if M.planetsLeft < 1 and not M.gameOver then
        M.gameOver = true
        local text, pos, c = lef.addEntityComponents("end message", 'uitext', 'position', 'color')
        text.align = 'center'
        text.width = 300
        text.text = "Well done! You have created a tiny solar system! You totally ROCK! Um. I couldn't think of an ending though. Press ESC to quit, or just watch planets collide."
        pos.x = 400 - text.width / 2
        pos.y = 450
        c:setColor(156, 255, 201)

        spawnPlanet(lef, {}, 400, 300, {255, 244, 53, 50}, 0, 0, 2, 0, true, "sun")
    end

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

        if #close > M.PLANET_DUST_NEEDED then
            spawnPlanet(lef, close, mx, my, COLORS[math.floor((#COLORS - 1) * math.random()) + 1])
            allowAccretion(false)
        else
            local r = 24
            local norm = #close / M.PLANET_DUST_NEEDED
            local shape, pos, c = lef.addEntityComponents("accretion cur", 'shape', 'position', 'color', 'ui')
            shape.type = 'circle'
            shape.params = {norm * r}
            c:setColor(159, 255 * norm, 41, 100)
            pos.x = mx
            pos.y = my

            local shape, pos, c = lef.addEntityComponents("accretion max", 'shape', 'position', 'color', 'ui')
            shape.type = 'circle'
            shape.fill = false
            shape.line = true
            shape.params = {r}
            c:setColor(159, 255, 41, 100)
            pos.x = mx
            pos.y = my
        end
    else
        for i, entity in ipairs(entities) do
            c = lef.entityComponents(entity, 'color')
            c:setColor(55, 55, 55)
        end
    end
end

return M
