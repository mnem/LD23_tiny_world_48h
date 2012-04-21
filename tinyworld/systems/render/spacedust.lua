local M = {}

M.components = {
    'position',
    'image',
    'spacedust'
}

M.priority = 1000

M.COLORS = {
    {0, 0, 0, 255},
    {136, 58, 80, 255},
    {81, 73, 133, 255},
    {238, 96, 232, 255},
    {0, 104, 84, 255},
    {146, 146, 146, 255},
    {0, 169, 235, 255},
    {203, 196, 244, 255},
}

function M.processor(entities, lef)
    love.graphics.setColorMode('modulate')
    local c
    for i, entity in ipairs(entities) do
        local pos, img, sd = lef.entityComponents(entity, 'position', 'image', 'spacedust')
        c = M.COLORS[sd.dustType]
        love.graphics.setColor(c[1], c[2], c[3], c[4])
        love.graphics.draw(img.image, pos.x, pos.y)
    end
end

return M
