-- Required libraries
local ui = require("ui")          -- For handling the UI components
local nativefs = require("nativefs") -- For handling file operations

-- Global variables
local canvas = nil                -- The canvas where drawing happens
local tool = "pencil"             -- Current selected drawing tool (pencil or eraser)
local canvasWidth, canvasHeight = 32, 32 -- Default canvas size
local pixelSize = 16              -- Size of each pixel on the screen

local scale = 1                   -- Default zoom level
local offsetX, offsetY = 200, 100 -- Position of the canvas on screen
local minZoom = 0.4               -- Minimum zoom-in limit
local maxZoom = 2.5               -- Maximum zoom-out limit

-- Flags to track visibility of file dialogs
local showSaveDialog = false
local showOpenDialog = false
local showExportDialog = false
local showImportDialog = false

-- File paths for saving, loading, exporting, and importing
local saveFilePath = ""
local loadFilePath = ""
local currentFilePath = nil
local exportFileName = ""
local importFileName = ""

-- Default selected color (black)
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

-- Initialize the application
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")  -- Nearest neighbor filtering for pixel art
    love.graphics.setBackgroundColor(0.6, 0.6, 0.6) -- Checkerboard background color
    createCanvas()  -- Create the initial canvas

    -- Create buttons for tools (New Canvas, Pencil, Eraser, etc.)
    ui.newButton(10, 10, 100, 30, "New Canvas", function ()
        canvas = love.graphics.newCanvas(canvasWidth, canvasHeight) -- Create new canvas
        createCanvas()  -- Reset canvas state
        currentFilePath = nil  -- Clear the current file path
    end)

    -- Button to select pencil tool
    ui.newButton(120, 10, 100, 30, "Pencil", function ()
        tool = "pencil"  -- Set the current tool to pencil
    end)

    -- Button to select eraser tool
    ui.newButton(230, 10, 100, 30, "Eraser", function ()
        tool = "eraser"  -- Set the current tool to eraser
    end)

    -- Button to save canvas
    ui.newButton(10, 100, 100, 30, "Save Canvas", function()
        print("Save button clicked!")
        if currentFilePath then
            saveCanvas()  -- Overwrite the current file
        else 
            local userFileName = "new_sprite"  -- Default name for new sprite
            showSaveDialog = true  -- Open save dialog
            saveCanvas(userFileName)  -- Save canvas
        end
    end)

    -- Button to open a saved canvas
    ui.newButton(10, 140, 100, 30, "Open Canvas", function()
        print("Open button clicked!")
        showOpenDialog = true  -- Open load dialog
    end)

    -- Button to export canvas as a PNG file
    ui.newButton(10, 180, 100, 30, "Export Canvas", function()
        print("Export button clicked!")
        showExportDialog = true  -- Open export dialog
    end)

    -- Button to import an image
    ui.newButton(10, 220, 100, 30, "Import Image", function()
        print("Import button clicked!")
        showImportDialog = true  -- Open import dialog
    end)

    -- Create color palette buttons
    local startX = 10
    local startY = 50
    for i, color in ipairs(colorPalette) do
        local x = startX + (i - 1) * 40
        ui.newColorButton(x, startY, 30, 30, color, function()
            selectedColor = color  -- Set the selected color
        end)
    end
end

-- Handle key presses for dialog interactions and file operations
function love.keypressed(key)
    if showSaveDialog then
        if key == "return" then
            saveCanvas(saveFilePath) -- Save the file with the selected path
            showSaveDialog = false -- Close dialog after saving
        elseif key == "escape" then
            showSaveDialog = false -- Cancel dialog
        end
    elseif showOpenDialog then
        if key == "return" then
            loadCanvas(loadFilePath) -- Load the file with the selected path
            showOpenDialog = false -- Close dialog after loading
        elseif key == "escape" then
            showOpenDialog = false -- Cancel dialog
        end
    elseif showExportDialog then
        if key == "return" then
            exportCanvas(exportFileName) -- Export the canvas to a file
            showExportDialog = false -- Close dialog after exporting
        elseif key == "escape" then
            showExportDialog = false -- Cancel dialog
        end
    elseif showImportDialog then
        if key == "return" then
            loadPng(importFileName) -- Load the image as PNG
            showImportDialog = false -- Close dialog after loading
        elseif key == "escape" then
            showImportDialog = false -- Cancel dialog
        end
    end

    -- Backspace functionality to delete characters in the input fields
    if key == "backspace" then
        loadFilePath = loadFilePath:sub(1, -2)
        saveFilePath = saveFilePath:sub(1, -2)
        exportFileName = exportFileName:sub(1, -2)
        importFileName = importFileName:sub(1, -2)
    end
end

-- Save the canvas to a file
function saveCanvas(filePath)
    local pathToSave = filePath or currentFilePath
    if not pathToSave then 
        print("No file path specified to save the canvas!")
        return
    end

    -- Ensure the file has the .speditor extension
    if not pathToSave:match("%.speditor$") then 
        pathToSave = pathToSave .. ".speditor" -- Append the extension if it's missing
    end

    if canvas then
        -- Save the canvas as a PNG file
        local imageData = canvas:newImageData()
        local encodedData = imageData:encode("png")

        -- Get the full path
        local workingDir = nativefs.getWorkingDirectory() -- Current working directory
        local fullPath = workingDir .. "/" .. pathToSave

        -- Write the encoded data to a file
        local file = io.open(fullPath, "wb") -- Open the file in binary write mode
        if file then
            file:write(encodedData:getString()) -- Write the PNG data as a string
            file:close()

            -- Update currentFilePath to the saved path
            currentFilePath = pathToSave

            -- Print confirmation
            print("Canvas saved as: " .. fullPath)
        else
            print("Failed to save canvas to: " .. pathToSave)
        end
    end
end

-- Function to load a canvas from a saved file
function loadCanvas(filePath)
    -- Ensure the file has the .speditor extension
    if not filePath:match("%.speditor$") then 
        filePath = filePath .. ".speditor"  -- Append the .speditor extension if missing
    end

    -- Proceed if the file path is valid
    if filePath then
        -- Get the full path to the file using the working directory
        local workingDir = nativefs.getWorkingDirectory()  -- Get the current working directory
        local fullPath = workingDir .. "/" .. filePath  -- Construct the full file path

        -- Try to open the file in binary read mode ("rb")
        local file = io.open(fullPath, "rb")
        if file then
            -- Read the entire file content
            local fileData = file:read("*all")  -- Read all bytes from the file
            file:close()  -- Close the file after reading

            -- Create image data from the file contents
            local imageData = love.image.newImageData(love.filesystem.newFileData(fileData, filePath))

            -- Create a new canvas with the loaded image dimensions
            canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)  -- Create a new canvas
            love.graphics.setCanvas(canvas)  -- Set the canvas to draw on
            love.graphics.clear(1, 1, 1, 0)  -- Clear the canvas with transparency
            love.graphics.setColor(1, 1, 1, 1)  -- Set color to white to draw the image
            love.graphics.draw(love.graphics.newImage(imageData))  -- Draw the image on the canvas
            love.graphics.setCanvas()  -- Reset the drawing context

            -- Update the current file path to the one that was loaded
            currentFilePath = filePath

            -- Print success message with the file path
            print("Canvas loaded from: " .. fullPath)
        else
            -- Print error message if the file couldn't be opened
            print("Failed to open file: " .. fullPath)
        end
    end
end

-- Function to export the canvas to a PNG
function exportCanvas(fileName)
    -- Check if a valid file name is provided
    if not fileName or fileName == "" then 
        print("No file name specified for export!")
        return
    end

    -- Ensure the file name has the .png extension
    if not fileName:match("%.png$") then 
        fileName = fileName .. ".png"  -- Append .png if missing
    end

    -- Proceed if the canvas exists
    if canvas then
        -- Convert the canvas to image data (pixel data of the canvas)
        local imageData = canvas:newImageData()
        
        -- Encode the image data into PNG format
        local encodedData = imageData:encode("png")

        -- Get the current working directory to construct the full file path
        local workingDir = nativefs.getWorkingDirectory() -- Retrieve the current working directory
        local fullPath = workingDir .. "/" .. fileName -- Construct full path with file name

        -- Open the file in binary write mode to write the PNG data
        local file = io.open(fullPath, "wb")  -- "wb" mode for binary write
        if file then
            file:write(encodedData:getString())  -- Write the PNG data as a string
            file:close()  -- Close the file after writing

            -- Update the export file name to the current file name
            exportFileName = fileName

            -- Print a success message with the full path of the saved file
            print("Canvas saved as: " .. fullPath)
        else
            -- Print an error message if the file could not be opened for writing
            print("Failed to export canvas to: " .. fileName)
        end
    end
end

-- Function to load a PNG file into the canvas
function loadPng(filePath)
    -- Check if filePath is provided, if not print an error
    if not filePath or filePath == "" then
        print("No file path provided for loading PNG!")
        return
    end

    -- Append .png to filePath if it's missing
    if not filePath:match("%.png$") then
        filePath = filePath .. ".png"
    end

    -- Get the current working directory
    local workingDir = nativefs.getWorkingDirectory()
    local fullPath = workingDir .. "\\" .. filePath -- Use backslash for Windows compatibility

    -- Debugging output to show paths
    print("Working Directory:", workingDir)
    print("Full Path:", fullPath)

    -- Verify if the file exists
    local fileExists = nativefs.getInfo(fullPath)
    if not fileExists then
        -- If file doesn't exist, print an error and return
        print("File not found at: " .. fullPath)
        return
    end

    -- Attempt to load the PNG image data
    local success, imageData, err = pcall(function()
        return love.image.newImageData(filePath)
    end)

    -- Test if the file can be opened directly (additional check)
    local testFile = io.open(fullPath, "r")
    if not testFile then
        print("io.open failed: File not accessible")
        return
    end
    testFile:close()  -- Close file after checking accessibility
    print("io.open succeeded: File is accessible")

    -- If loading the image failed, print an error message
    if not success or not imageData then
        print("Failed to load PNG from: " .. fullPath .. " Error: " .. tostring(err))
        return
    end

    -- Resize the canvas to match the dimensions of the loaded PNG image
    canvasWidth, canvasHeight = imageData:getWidth(), imageData:getHeight()
    createCanvas()  -- Call createCanvas to create a new canvas of the correct size

    -- Draw the loaded PNG image onto the canvas
    local image = love.graphics.newImage(imageData)
    love.graphics.setCanvas(canvas)  -- Set the current canvas to the new canvas
    love.graphics.clear(1, 1, 1, 0) -- Clear the canvas with transparency (transparent background)
    love.graphics.draw(image, 0, 0)  -- Draw the image at position (0, 0)
    love.graphics.setCanvas()  -- Reset the canvas to default

    -- Output success message with the full path of the loaded PNG
    print("PNG loaded successfully from: " .. fullPath)
end

-- Function to create a new canvas with specified width and height
function createCanvas()
    -- Create a new canvas with the given dimensions and format (rgba8)
    canvas = love.graphics.newCanvas(canvasWidth, canvasHeight, {format = "rgba8"})
    love.graphics.setCanvas(canvas)  -- Set the current canvas to the newly created one
    love.graphics.clear(1, 1, 1, 0) -- Clear the canvas with transparency (transparent background)
    love.graphics.setCanvas()  -- Reset the canvas to default
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- When the mouse is moved and the left button is held down, draw a pixel
    if love.mouse.isDown(1) then
        drawPixel(x, y)  -- Draw a pixel at the mouse position
    end
end

function love.wheelmoved(x, y)
    -- Zoom in or out based on mouse wheel movement
    if y ~= 0 then 
        -- Get mouse position relative to the canvas
        local mouseX, mouseY = love.mouse.getPosition()

        -- Calculate the mouse position on the canvas
        local canvasMouseX = (mouseX - offsetX) / scale
        local canvasMouseY = (mouseY - offsetY) / scale

        -- Update scale (zoom in/out)
        local zoomFactor = 1.1 -- Zoom increment
        local oldScale = scale
        if y > 0 then 
            scale = scale * zoomFactor -- Zoom in
        elseif y < 0 then
            scale = scale / zoomFactor -- Zoom out
        end

        -- Apply the zoom limits
        if scale < minZoom then
            scale = minZoom  -- Ensure the scale doesn't go below minZoom
        elseif scale > maxZoom then
            scale = maxZoom  -- Ensure the scale doesn't exceed maxZoom
        end

        -- Adjust the canvas offset to maintain pointer position during zoom
        local zoomDelta = scale / oldScale
        offsetX = mouseX - (mouseX - offsetX) * zoomDelta
        offsetY = mouseY - (mouseY - offsetY) * zoomDelta
    end
end

function drawPixel(x, y)
    -- Convert screen coordinates to canvas pixel coordinates
    local canvasX = math.floor((x - offsetX) / (pixelSize * scale))
    local canvasY = math.floor((y - offsetY) / (pixelSize * scale))

    -- Ensure we're within the canvas bounds before drawing
    if canvas and canvasX >= 0 and canvasY >= 0 and canvasX < canvasWidth and canvasY < canvasHeight then
        love.graphics.setCanvas(canvas)

        if tool == "pencil" then
            -- Pencil tool: draw with the selected color
            love.graphics.setBlendMode("alpha", "premultiplied")
            love.graphics.setColor(selectedColor[1], selectedColor[2], selectedColor[3], 1)
        elseif tool == "eraser" then
            -- Eraser tool: make the pixel transparent
            love.graphics.setBlendMode("replace")
            love.graphics.setColor(0, 0, 0, 0)
        end

        -- Draw the pixel as a rectangle
        love.graphics.rectangle("fill", canvasX, canvasY, 1, 1)

        -- Reset blend mode to default after drawing
        love.graphics.setBlendMode("alpha")
        love.graphics.setCanvas()
    end
end

function love.draw()
    -- Draw the checkerboard background for the canvas grid
    drawCheckerboard(offsetX, offsetY, canvasWidth * pixelSize * scale, canvasHeight * pixelSize * scale)

    -- Draw the canvas with scaling applied
    if canvas then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(canvas, offsetX, offsetY, 0, pixelSize * scale, pixelSize * scale)  -- Apply scaling to the canvas
    end

    -- Draw the UI elements like tool selection buttons
    ui.draw()

    -- Show save dialog and input field
    if showSaveDialog then
        love.graphics.setColor(0, 0, 0, 1)  -- Semi-transparent overlay for dialog
        love.graphics.rectangle("line", 400, 10, 300, 30)  -- Input box outline
        love.graphics.print("Enter file name:", 405, 17)  -- Label for file name input
        love.graphics.print(saveFilePath, 503, 17)  -- Display entered text for file name
    end

    -- Show open dialog and input field
    if showOpenDialog then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("line", 400, 10, 300, 30)  -- Input box outline
        love.graphics.print("Enter file name:", 405, 17)  -- Label for file name input
        love.graphics.print(loadFilePath, 503, 17)  -- Display entered text for file name
    end

    -- Show export dialog and input field
    if showExportDialog then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("line", 400, 10, 300, 30)  -- Input box outline
        love.graphics.print("Enter file name:", 405, 17)  -- Label for file name input
        love.graphics.print(exportFileName, 503, 17)  -- Display entered text for file name
    end

    -- Show import dialog and input field
    if showImportDialog then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("line", 400, 10, 300, 30)  -- Input box outline
        love.graphics.print("Enter file name:", 405, 17)  -- Label for file name input
        love.graphics.print(importFileName, 503, 17)  -- Display entered text for file name
    end
end

function love.textinput(text)
    -- Handle text input for various file dialogs
    if showSaveDialog then
        -- Append text input to save file path
        saveFilePath = saveFilePath .. text
    elseif showOpenDialog then
        -- Append text input to load file path
        loadFilePath = loadFilePath .. text
    elseif showExportDialog then
        -- Append text input to export file name
        exportFileName = exportFileName .. text
    elseif showImportDialog then
        -- Append text input to import file name
        importFileName = importFileName .. text
    end
end

function drawCheckerboard(x, y, width, height)
    -- Draw a checkerboard pattern as the canvas background
    local size = 16  -- Size of each checkerboard square
    for i = 0, math.ceil(width / size) - 1 do
        for j = 0, math.ceil(height / size) - 1 do
            local isDark = (i + j) % 2 == 0  -- Alternate dark and light squares
            if isDark then
                love.graphics.setColor(0.7, 0.7, 0.7)  -- Dark square color
            else
                love.graphics.setColor(0.9, 0.9, 0.9)  -- Light square color
            end
            -- Draw the checkerboard square at the correct position
            love.graphics.rectangle("fill", x + i * size, y + j * size, size, size)
        end
    end
end