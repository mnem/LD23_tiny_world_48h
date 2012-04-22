local M = {}

M.components = {
    'position',
    'linearvelocity',
}

function M.processor(entities, lef)
    local dt = love.timer.getDelta()
    for i, entity in ipairs(entities) do
        local pos, vel = lef.entityComponents(entity, 'position', 'linearvelocity')
        pos.x = pos.x + (vel.dx * dt)
        pos.y = pos.y + (vel.dy * dt)

        if pos.x > 800 then
            pos.x = pos.x - 800
        elseif pos.x < 0 then
            pos.x = pos.x + 800
        end

        if pos.y > 600 then
            pos.y = pos.y - 600
        elseif pos.y < 0 then
            pos.y = pos.y + 600
        end
    end
end

return M
