local spacedust = require 'tinyworld.systems.render.spacedust'
local log = require 'tinyworld.log'
local lef = require 'nah.lef'
local unitTests = false

if unitTests then
    local lefTests = require 'nah.tests.lef'
    lefTests.print = log.msg
    lefTests.runAll()
    lefTests.printResults()
    function love.draw()
        log.draw()
    end
else
    -- Send lef messages to the screen log
    lef.print = log.msg

    local function initBackground()
        love.graphics.setBackgroundColor(46, 36, 113, 255)

        local backgroundClouds = love.graphics.newImage('assets/images/cloud_back.png')
        local backimg, vel, pos, c
        backimg, vel, pos, c = lef.addEntityComponents('bg2', 'image', 'linearvelocity', 'position', 'color', 'background')
        backimg.image = backgroundClouds
        backimg.colorMode = 'modulate'
        c:setColor(9, 110, 74, 80)
        vel:setSpeed(-13, 0)
        pos.x = 800 * math.random()

        backimg, vel, pos, c = lef.addEntityComponents('bg0', 'image', 'linearvelocity', 'position', 'color', 'background')
        backimg.image = backgroundClouds
        backimg.colorMode = 'modulate'
        c:setColor(255 * math.random(), 255 * math.random(), 255 * math.random(), 200)
        vel:setSpeed(0, 3)
        pos.y = 600 * math.random()

        backimg, vel, pos, c = lef.addEntityComponents('bg1', 'image', 'linearvelocity', 'position', 'color', 'background')
        backimg.image = backgroundClouds
        backimg.colorMode = 'modulate'
        c:setColor(67, 10, 49, 100)
        vel:setSpeed(7, 0)
        pos.x = 800 * math.random()
    end

    local function initSpaceDust()
        local dust = love.graphics.newImage('assets/images/space_dust.png')
        local img, pos, vel, sd
        for i=1, 700 do
            img, pos, vel, sd, c = lef.addEntityComponents(
                'dust'..i,
                'image',
                'position',
                'linearvelocity',
                'spacedust',
                'color',
                'accrete')
            img.image = dust
            pos.x = 800 * math.random()
            pos.y = 600 * math.random()
            vel.dx = 20 * math.random() - 10
            vel.dy = 20 * math.random() - 10
            c:setColor(55, 55, 55)
        end
    end

    function love.load()
        lef.registerAllComponentsIn('tinyworld/components')
        lef.addAllSystemGroupsIn('tinyworld/systems')

        initBackground()
        initSpaceDust()
        -- Create the entity that follows the cursor
        local cursimg = lef.addEntityComponents('cursor', 'image', 'active cursor', 'position')
        cursimg.image = love.graphics.newImage('thing.png')
        cursimg.ox = cursimg.image:getWidth() / 2
        cursimg.oy = cursimg.image:getHeight() / 2
    end

    function love.draw()
        lef.updateSystem('render')
        --log.draw()
    end

    function love.update()
        lef.updateSystem('logic')
    end
end
