-- Module exports
local M = {}

local messages = {}

function M.clear()
    messages = {}
end

function M.msg(message)
    table.insert(messages, message)
    print(message)
end

function M.draw(x, y)
    x = x or 0
    y = y or 0
    love.graphics.setColorMode('replace')
    for i, message in ipairs(messages) do
        love.graphics.print(message, x, y)
        y = y + 18
    end
end

return M
