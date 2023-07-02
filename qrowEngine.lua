-- Kaffeehaus Games Official Library

-- ~~ LOAD SDL ~~ --
SDL = require("SDL")
image = require("SDL.image")

-- Load SDL images
local formats, ret, err = image.init{ image.flags.PNG }

if not formats[image.flags.PNG] then
    error(err)
end

-- Initialize video and audio
local ret, err = SDL.init {
	SDL.flags.Video,
	SDL.flags.Audio
}

if not ret then
	error(err)
end

-- ~~ GENERAL ~~ --

exitIsPressed = false

mouseState = nil
mouseX = 0
mouseY = 0

win, err = assert(SDL.createWindow{
    title = "Qrow Game",
    width = 800,
    height = 600,
})

function setWindow(name, w, h)
    win:setTitle(name)
    win:setSize(w, h)
end

-- ~~ GRAPHICS ~~ --

-- create a renderer for graphics
render = assert(SDL.createRenderer(win, 0, 0))

-- load images
function loadImage(path_to_sprite)
    this = assert(image.load(path_to_sprite))
    this = render:createTextureFromSurface(this)
    return this
end

-- draw images
function drawImage(image, imageRect)
    render:copy(image, nil, imageRect)
end

-- clear screen
function clear()
    render:setDrawColor(0xFFFFFF)
    render:clear()
end

-- gotta figure out a way to load spritesheets / animate
-- ...
-- shouldn't be too hard.
-- For now let's focus on input.

-- ~~ INPUT ~~ --

keysHeld = {}
keysPressed = {}

function checkKeyDown(key)
    for i, v in ipairs(keysHeld) do
        if v == key then
            return true
        end
    end

    return false

end

function checkKeyPressed(key)
    for i, v in ipairs(keysPressed) do
        if v == key then
            keysPressed = {}
            return true
        end
    end

    return false

end


function getKeys()
    for e in SDL.pollEvent() do
        if e.type == SDL.event.Quit then
            exitIsPressed = true
        elseif e.type == SDL.event.KeyDown then
            table.insert(keysHeld, SDL.getKeyName(e.keysym.sym))
            table.insert(keysPressed, SDL.getKeyName(e.keysym.sym))
            --print(SDL.getKeyName(e.keysym.sym))
        elseif e.type == SDL.event.KeyUp then
            for i, v in ipairs(keysHeld) do
                if v == SDL.getKeyName(e.keysym.sym) then
                    table.remove( keysHeld, i)
                end
            end
        end
    end
end

-- ~~ COLLISION ~~ --

boxes = {}

function createCollisionBox(objRect, w, h)
    objRect.bbox = {object = objRect, x = objRect.x, objRect.y, w = w, h = h}
    table.insert(boxes, objRect.bbox)
end

function checkOverlap(box1, box2)
    if box1.x < box2.x + box2.w and
    box1.x + box1.w > box2.x and
    box1.y < box2.y + box2.h and
    box1.h + box1.y > box2.y then
        return true
    end
    
    return false
    
end

function advancedOverlap(x1, x2, y1, y2, w1, w2, h1, h2)
    if x1 < x2 + w2 and
    x1 + w1 > x2 and
    y1 < y2 + h2 and
    h1 + y1 > y2 then
        return true
    end
    
    return false
end

function bonkUpdate()
    for i, b in ipairs(boxes) do
        b.x = b.object.x
        b.y = b.object.y
    end
end

function showCollisionBoxes()
    render:setDrawColor(0xff0000)
    for i, b in ipairs(boxes) do
        render:drawRect(b)
    end
end

-- ~~ TICK ~~ --

function tick()
    mouseState, mouseX, mouseY = SDL.getMouseState()
    getKeys()
    bonkUpdate()
    render:present()
    clear()
    SDL.delay(7)    -- This controls framerate, the lower it goes, the higher framerate is.
end
