local M = {}

M.components = {
    'color',
    'position',
    'shape',
    'ui'
}

M.priority = 10

function M.processor(entities, lef)
    love.graphics.setColorMode('modulate')
    for i, entity in ipairs(entities) do
        local pos, shp, c = lef.entityComponents(entity, 'position', 'shape', 'color')
        love.graphics.setColor(c.red, c.green, c.blue, c.alpha)
        if shp.fill then
            love.graphics[shp.type]('fill', pos.x, pos.y, unpack(shp.params))
        end
        if shp.line then
            love.graphics[shp.type]('line', pos.x, pos.y, unpack(shp.params))
        end
    end
end

return M
