local sl = {}
local sounds = {}

local function recursiveindexsfx(sfx, path)
    local ft = love.filesystem.getInfo(path)
    --print("recursion : " .. path)
    if ft == "file" then
        local sd = love.sound.newSoundData(sfx)
        sounds[path] = sd
    else
        for _, thing in pairs(love.filesystem.getDirectoryItems(path)) do
            recursiveindexsfx(thing, path .. "/" .. thing)
        end
    end
end

--recursiveindexsfx(nil, "sfx")


function sl.qsfx(supercategory, objtype, subcategory, volume)
    local avalible = love.filesystem.getDirectoryItems("sfx/" .. supercategory .. "/" .. objtype .. "/" .. subcategory)
    local pick = love.math.random(#avalible)
    for i, sfx in pairs(avalible) do
        if i == pick then
            local path = "sfx/" .. supercategory .. "/" .. objtype .. "/" .. subcategory .. "/" .. sfx
            --local sd = sounds[path]
            local source = love.audio.newSource(path, "static")
            source:setVolume(volume)
            source:setPitch(math.random(95, 105) * 0.01)
            love.audio.play(source)
        end
    end
end
function sl.obj(objtype, subcategory)
    sl.qsfx("object", objtype, subcategory, 0.25)
end
function sl.bird(color, sfx)
    sl.qsfx("bird", color, sfx, 1)
end
function sl.direct(path)

end
local bgsource = nil
local regularbgvol = 0.25
local bgvol = regularbgvol
local bgsloop = 0
function sl.updatebgmusic()
    if bgsource == nil or bgsource:isPlaying() == false then
        bgsloop = bgsloop + 1
        local list = love.filesystem.getDirectoryItems("sfx/music/main")
        if bgsloop > #list then
            bgsloop = 1
        end
        for i, bg in pairs(love.filesystem.getDirectoryItems("sfx/music/main")) do -- may need to fix later, might not loop normally unless lua file looping is deteministic which im hoping it is
            if i == bgsloop then
                bgsource = love.audio.newSource("sfx/music/main/" .. bg, "static")
                bgsource:setVolume(bgvol)
                love.audio.play(bgsource)
            end
        end
    end
end
function sl.mutebg()
    if bbgvol == 0 then
        
        bgvol = regularbgvol
        bgsource:setVolume(bgvol)
    else
        bgsource:setVolume(0)
        bgvol = 0
    end
end

return sl