local ui = require("ui")

local canvas = nil
local tool = "pencil" -- Default tool
local canvasWidth, canvasHeight = 32, 32 -- Default canvas size
local pixelSize = 16 --  Size of each pixel on the screen

-- Default selected color
local selectedColor = {0, 0, 0}

-- Predefined color palette
local colorPalette = {
    {0, 0, 0},        -- Black
    {1, 1, 1},        -- White
    {1, 0, 0},        -- Red
    {0, 1, 0},        -- Green
    {0, 0, 1},        -- Blue
    {1, 1, 0},        -- Yellow
    {1, 0, 1},        -- Magenta
    {0, 1, 1},        -- Cyan
}

function love.load()
    love.graphics.setBackgroundColor(0.6, 0.6, 0.6) -- Checkerboard background
    createCanvas()

    -- Buttons for tools
    ui.newButton(10, 10, 120, 30, "New Canvas", function ()
        canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
        createCanvas()
    end)

    ui.newButton(120, 10, 100, 30, "Pencil", function ()
        tool = "pencil"
    end)

    ui.newButton(230, 10, 100, 30, "Eraser", function ()
        tool = "eraser"
    end)

    local startX = 10
    local startY = 50
    for i, color in ipairs(colorPalette) do 
        ui.newColorButton(startX + (i - 1) * 40, startY, 30, 30, color, function()
            selectedColor = color
        end)
    end
end

function createCanvas()
    canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(1, 1, 1, 0) -- Clear with transparency
    love.graphics.setCanvas()
end

function love.mousemoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(1) then
        drawPixel(x, y)
    end
end

function drawPixel(x, y)
    local canvasX = math.floor((x - 200) / pixelSize) -- Adjust for canvas offset
    local canvasY = math.floor((y - 100) / pixelSize)

    if canvas and canvasX >= 0 and canvasY >= 0 and canvasX < canvasWidth and canvasY < canvasHeight then
        love.graphics.setCanvas(canvas)
        love.graphics.setColor(selectedColor)
        love.graphics.rectangle("fill", canvasX, canvasY, 1, 1)
        love.graphics.setCanvas()
    end
end

function love.draw()
    -- Draw checkerboard background
    drawCheckerboard(200, 100, canvasWidth * pixelSize, canvasHeight * pixelSize)

    -- Draw canvas
    if canvas then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(canvas, 200, 100, 0, pixelSize, pixelSize)
    end

    -- Draw UI
    ui.draw()
end

function drawCheckerboard(x, y, width, height)
    local size = 16 -- Checkerboard square size
    for i = 0, math.ceil(width / size) - 1 do
        for j = 0, math.ceil(height / size) - 1 do
            local isDark = (i + j) % 2 == 0
            if isDark then
                love.graphics.setColor(0.7, 0.7, 0.7)
            else
                love.graphics.setColor(0.9, 0.9, 0.9)
            end
            love.graphics.rectangle("fill", x + i * size, y + j * size, size, size)
        end
    end
end