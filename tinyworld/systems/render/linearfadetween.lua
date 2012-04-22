local M = {}

M.components = {
    'tween',
    'color',
    'fadeout',
}

M.priority = 0

function M.processor(entities, lef)
    love.graphics.setColorMode('replace')
    for i, entity in ipairs(entities) do
        local fade, c = lef.entityComponents(entity, 'tween', 'color')
        local life = (love.timer.getMicroTime() - fade.birth) / fade.time
        if life > 1 then
            -- Finished
            lef.destroyEntity(entity)
        else
            love.graphics.setColor(c.red, c.green, c.blue, c.alpha - c.alpha * life)
            love.graphics.rectangle('fill', 0, 0, 800, 600)
        end
    end
end

return M
