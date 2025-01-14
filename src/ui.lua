local ui = {}

local buttons = {}
local colorButtons = {}

function ui.newButton(x, y, width, height, text, onClick)
    table.insert(buttons, {x = x, y = y, width = width, height = height, text = text, onClick = onClick})
end

function ui.newColorButton(x, y, width, height, color, onClick)
    table.insert(colorButtons, {x = x, y = y, width = width, height = height, color = color, onClick = onClick})
end

function ui.draw()
    -- Draw regular buttons
    for _, button in ipairs(buttons) do
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        if button.text then -- Check if text exists
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(button.text, button.x + 10, button.y + 10)
        end
    end

    -- Draw color buttons
    for _, colorButton in ipairs(colorButtons) do
        love.graphics.setColor(colorButton.color)
        love.graphics.rectangle("fill", colorButton.x, colorButton.y, colorButton.width, colorButton.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", colorButton.x, colorButton.y, colorButton.width, colorButton.height)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if x > btn.x and x < btn.x + btn.width and y > btn.y and y < btn.y + btn.height then
                btn.onClick()
            end
        end

        for _, colorButton in ipairs(colorButtons) do
            if x > colorButton.x and x < colorButton.x + colorButton.width and y > colorButton.y and y < colorButton.y + colorButton.height then
                colorButton.onClick()
            end
        end
    end
end

return ui