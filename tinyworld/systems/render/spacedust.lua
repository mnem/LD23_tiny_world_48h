local M = {}

M.components = {
    'position',
    'image',
    'spacedust'
}

M.priority = 1000

M.COLORS = {
    -- {0, 0, 0},
    {136, 58, 80},
    {81, 73, 133},
    -- {238, 96, 232},
    {0, 104, 84},
    -- {146, 146, 146},
    -- {0, 169, 235},
    -- {203, 196, 244},
}

function M.processor(entities, lef)
    love.graphics.setColorMode('modulate')
    local c
    for i, entity in ipairs(entities) do
        local pos, img, sd = lef.entityComponents(entity, 'position', 'image', 'spacedust')
        c = M.COLORS[sd.dustType]
        love.graphics.setColor(c[1], c[2], c[3], sd.alpha)
        love.graphics.draw(img.image, pos.x, pos.y)
    end
end

return M
