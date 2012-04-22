local M = {}

M.components = {
    'tween',
}

M.priority = 0

function M.processor(entities, lef)
    love.graphics.setColorMode('replace')
    for i, entity in ipairs(entities) do
        local tween = lef.entityComponents(entity, 'tween')
        local c = lef.entityComponents(entity, tween.component)
        local life = (love.timer.getMicroTime() - (tween.birth + tween.delay)) / tween.time
        if life > 1 then
            -- Finished
            lef.removeEntityComponents(entity, 'tween')
            if tween.onFinish ~= nil then
                tween.onFinish(entity)
            end
        elseif life >= 0 then
            c[tween.key] = ((tween.to - tween.from) * life) + tween.from
        end
    end
end

return M
