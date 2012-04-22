local M = {}

M.components = {
    'position',
    'image',
    'background',
    'color',
}

M.priority = 1500

function M.processor(entities, lef)
    love.graphics.setColorMode('modulate')
    for i, entity in ipairs(entities) do
        local pos, img, c = lef.entityComponents(entity, 'position', 'image', 'color')
        love.graphics.setColor(c.red, c.green, c.blue, c.alpha)
        love.graphics.draw(img.image, pos.x, pos.y)

        if pos.x > 0 then
            love.graphics.draw(img.image, pos.x - 800, pos.y)
        elseif pos.x < 0 then
            love.graphics.draw(img.image, pos.x + 800, pos.y)
        end

        if pos.y > 0 then
            love.graphics.draw(img.image, pos.x, pos.y - 600)
        elseif pos.y < 0 then
            love.graphics.draw(img.image, pos.x, pos.y + 600)
        end
    end
end

return M
