local M = {}

M.components = {
    'color',
    'position',
    'uitext',
}

M.priority = 10

function M.processor(entities, lef)
    love.graphics.setColorMode('modulate')
    for i, entity in ipairs(entities) do
        local pos, txt, c = lef.entityComponents(entity, 'position', 'uitext', 'color')
        love.graphics.setColor(c.red, c.green, c.blue, c.alpha)
        love.graphics.printf(txt.text, pos.x, pos.y, txt.width, txt.align)
    end
end

return M
