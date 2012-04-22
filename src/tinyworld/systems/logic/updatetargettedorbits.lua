local M = {}

M.components = {
    'position',
    'linearvelocity',
    'orbittarget'
}

local MAX_S = 20
local ACCEL = 1.5

function M.processor(entities, lef)
    local pos, vel, trg, tx, ty
    for i, entity in ipairs(entities) do
        pos, vel, trg = lef.entityComponents(entity, 'position', 'linearvelocity', 'orbittarget')

        tx = trg.target.x
        ty = trg.target.y
        x = pos.x - tx
        y = pos.y - ty
        d = x * x + y * y
        if d > trg.radiusradius then
            -- Move towards the point
            if pos.x > tx then
                vel.dx = vel.dx - ACCEL
                if vel.dx < -MAX_S then vel.dx = -MAX_S end
            end
            if pos.x < tx then
                vel.dx = vel.dx + ACCEL
                if vel.dx > MAX_S then vel.dx = MAX_S end
            end
            if pos.y > ty then
                vel.dy = vel.dy - ACCEL
                if vel.dy < -MAX_S then vel.dy = -MAX_S end
            end
            if pos.y < ty then
                vel.dy = vel.dy + ACCEL
                if vel.dy > MAX_S then vel.dy = MAX_S end
            end
        end
    end
end

return M
