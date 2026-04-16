local texlib = {}

local pig = love.graphics.newImage("textures/pig_alt.jpg")
local slingshot = love.graphics.newImage("textures/slingshot.jpg")
local restart = love.graphics.newImage("textures/restart_level.png")
local bird = {}
local button = {}
--bird.red = love.graphics.newImage("textures/bird_red.jpg")

for _, image in pairs(love.filesystem.getDirectoryItems("textures/birds")) do
    local name = string.sub(image, 1, string.len(image) - 4)
    bird[name] = love.graphics.newImage("textures/birds/" .. image)
end
for _, image in pairs(love.filesystem.getDirectoryItems("textures/buttons")) do
    local name = string.sub(image, 1, string.len(image) - 4)
    button[name] = love.graphics.newImage("textures/buttons/" .. image)
end

function texlib.pig()
    return pig
end
function texlib.slingshot()
    return slingshot
end
function texlib.restart()
    return restart
end
function texlib.bird(color)
    return bird[color]
end
function texlib.birds()
    return bird
end
function texlib.buttons()
    return button
end
function texlib.btnsiz()
    return 110
end
function texlib.truebtnsiz()
    return 156
end

return texlib


