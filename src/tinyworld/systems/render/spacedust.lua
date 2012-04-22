local M = {}

M.components = {
    'position',
    'image',
    'spacedust',
    'color',
}

M.priority = 1000

function M.processor(entities, lef)
    love.graphics.setColorMode('modulate')
    for i, entity in ipairs(entities) do
        local pos, img, sd, c = lef.entityComponents(entity, 'position', 'image', 'spacedust', 'color')
        love.graphics.setColor(c.red, c.green, c.blue, c.alpha)
        love.graphics.draw(img.image, pos.x, pos.y)
    end
end

return M
