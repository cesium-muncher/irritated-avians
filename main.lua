--[[
ok how abt
each level is a script
that spawns in everything n stuff
and main is js the fisiks

data structure = {{type, x, y, sx, sy, rot}, {}, {}...}
type is: pig, wood, stone, ice

here data structure = {{sx, sy(blocks only), shape, body, fixture}}
bird struct = {id, color, shape, body, fixture}

]]




screensizemult = 1
local scrw, scrh = love.window.getDesktopDimensions()
print(scrw .. " / " .. scrh .. " / " ..  scrw/scrh)
print("800 / 600 /" .. 800/600)
screensizemult = scrw/800 * 0.9
hssm = scrw/800 * 0.9
if scrw/scrh > 4/3 then
    screensizemult = scrh/600 * 0.9
end
whratio = 800 * screensizemult, 600 * screensizemult
screensizemult = 1
hssm = 800
-- most of this stuff is unnessesary, ssm and hssm are updated every frame.
love.window.setMode(800 * screensizemult, 600 * screensizemult, {resizable=true})

love.window.setIcon(love.image.newImageData("textures/birds/red.jpg"))
love.window.setTitle("Irritated Avians")
love.graphics.setBackgroundColor(0.2,0.7,1)
paused = false
blocks = {}
birds = {}
pigs = {}
ground = {}
world = love.physics.newWorld(0, 200)
local currentbirdid = 1
local smoothbirdmovement = 1
local smoothbirdmovementspeed = 2
local level = 1
local endlevel = false
local levlib = require "levellibrary"
local texlib = require "texturelibrary"
local parlib = require "particlelibrary"
local sfxlib = require "sfxlibrary"

audiomuted = false
local following = nil
local camerax, cameray = 0, 0
local lockeverythingforspawnlevel = false
--cam:setPosition(0000,2000)
local screenshake = 0
levlib.ground()
function spawnlevel(number)
    -- clear previous level
    lockeverythingforspawnlevel = true
    currentbirdid = 1
    smoothbirdmovement = 1

    for pi, pig in pairs(pigs) do  
        pig[3]:setPosition(8000, -8000) 
        pig[4]:destroy()
        pig[3]:destroy()
    end

    for bi, bird in pairs(birds) do  
        bird[4]:setPosition(8000, -8000) 
        bird[5]:destroy()
        bird[4]:destroy()
    end
    for wi, wood in pairs(blocks) do  
        wood[4]:setPosition(8000, -8000)  
        wood[5]:destroy()
        wood[4]:destroy()
    end
    pigs = {}
    birds = {}
    blocks = {}
    following = nil
    parlib.clearall()

    -- make new level
    
    print("loading level")
    local name = "levels/level_" .. number
    local exists = love.filesystem.getInfo(name .. ".lua")
    if exists == nil then
        name = "levels/level_win"
        level = 99999
    end
    local level = require(name)
    levlib.decode(level)
    print("loaded")

    -- reload game loop

    
    lockeverythingforspawnlevel = false


end

function detectcollisonintable(table, i1, i2, body)-- i1 and i2 are where to store the collision info. 7 and 8 in wood blocks.
    local pvx, pvy = table[i1], table[i2]
    local nvx, nvy = body:getLinearVelocity()
    if pvx == nil then
        pvx, pvy = nvx, nvy
    end
    table[i1] = nvx
    table[i2] = nvy
    local vpvel = math.sqrt(pvx^2 + pvy^2)
    local vnvel = math.sqrt(nvx^2 + nvy^2)
    return vpvel, vnvel
end

function buttondetect(mx, my, bx, by, w, h)
    return (mx > bx-0.5*w and mx < bx+0.5*w and my > by-0.5*h and my < by+0.5*h)
end
function buttondetectcircle(mx, my, bx, by, r)
    return ((mx-bx)^2 + (my-by)^2 < r^2)
end
function buttondetect4(mx, my, bx1, bx2, by1, by2)
    local bx = (bx1+bx2)/2
    local by = (by1+by2)/2
    local w = math.abs(bx1-bx2)
    local h = math.abs(by1-by2)
    return buttondetect(mx, my, bx, by, w, h)
end

function buttondetectresetpreset(mx, my)
    return buttondetect4(mx, my, 15 * screensizemult, 64 * screensizemult, 15 * screensizemult, 60 * screensizemult)
end

function buttondetectdefaultpreset(mx, my, bx, by, m)
    return buttondetectcircle(mx, my, bx, by, texlib.btnsiz()/2 * 0.75 * m)
end
function cblg(x, y) -- center button location gen
    local cx, cy = 400*hssm, 300*screensizemult
    return cx + x*screensizemult*100, cy + y*screensizemult*100
end
function cblgx(x) -- center button location gen
    local cx = 400*hssm
    return cx + x*screensizemult*100
end
function cblgy(y) -- center button location gen
    local cy = 300*screensizemult
    return cy + y*screensizemult*100
end
function menubtndct(x, y, bx, by)
    return buttondetectdefaultpreset(x, y, cblgx(bx), cblgy(by), screensizemult)
end

function lerp(v1, v2, percent)
    return (v2 * percent) + (v1 * (1-percent))
end

function love.update(dt)
    
    if lockeverythingforspawnlevel then
        return
    end
    if paused then
        return
    end
    local explodingrnplswait = false -- makes acceleration not cause block breaking, required for explosions to look cool
    screenshake = math.max(screenshake - dt*screenshake - dt, 0)
    parlib.particlestep(dt)
    world:update(dt)
    for bi, bird in pairs(birds) do
        local bod = bird[4]
        local i = bird[1]
        local nowi = i - currentbirdid + 1
        local snowi = i - smoothbirdmovement + 1
        if i >= currentbirdid then
            bod:setPosition(-snowi * 55 + 150, 450 + snowi * 5)
            bod:setAngle(0)
            bod:setAngularVelocity(0)
        else
            local vpvel, vnvel = detectcollisonintable(bird, 7, 8, bod)
            local bx, by = bod:getPosition()
            if math.max(vpvel - vnvel) > 20 then
                sfxlib.bird(bird[2], "hit")
                if bird[2] == "black" and bird.exploded == nil then
                    bird.exploded = true
                    explodingrnplswait = true -- makes acceleration not cause block breaking, required for explosions to look cool

                    local distmult = 100
                    local strengthmult = 2
                    -- explosion
                    sfxlib.bird("black", "explode")
                    screenshake = screenshake + 0.2
                    for i=1, 6 do
                        parlib.boom(bod:getPosition())
                    end
                    for pi, pig in pairs(pigs) do
                        local explbody = pig[3]
                        local ex, ey = explbody:getPosition()
                        local dist = math.sqrt((bx-ex)^2 + (by-ey)^2)
                        local strength = 2^(-dist/distmult) * 200 * strengthmult -- percent
                        local vecx, vecy = (ex - bx)/dist * strength, (ey - by)/dist * strength
                        local oldx, oldy = explbody:getLinearVelocity()
                        explbody:setLinearVelocity(oldx + vecx, oldy + vecy)
                    end
                    for wi, wood in pairs(blocks) do
                        local explbody = wood[4]
                        local ex, ey = explbody:getPosition()
                        local dist = math.sqrt((bx-ex)^2 + (by-ey)^2)
                        local strength = 2^(-dist/distmult) * 200 * strengthmult -- percent
                        local vecx, vecy = (ex - bx)/dist * strength, (ey - by)/dist * strength
                        local oldx, oldy = explbody:getLinearVelocity()
                        explbody:setLinearVelocity(oldx + vecx, oldy + vecy)
                    end
                    bird[4]:setPosition(0, 80000)
                    bird[4]:setLinearVelocity(0, 9000)
                    birds[bi] = nil
                end
                if bird[2] == "j" then
                    activatememoryleak = true
                    screenshake = screenshake + 1
                    print("impending doom")
                    for i=1, 60 do
                        parlib.boom(bod:getPosition())
                        parlib.poof(bod:getPosition())
                        parlib.smoke(bod:getPosition())
                    end
                end
                
            end
        end
        for pi, pig in pairs(pigs) do
            local distance, x1, y1, x2, y2 = love.physics.getDistance(bird[5], pig[4])
           
            if distance < 3 then
                local px, py = pig[3]:getPosition()
                for i=1, 4 do
                    parlib.smoke(px + math.random(-10, 10), py + math.random(-10, 10))
                    parlib.poof(px, py)
                    --levlib.spawnpigidk(px + math.random(-10, 10), py + 25)
                end
                pig[4]:destroy()
                --pig[3]:destroy()
                pigs[pi] = nil
            end
        end




    end
    if smoothbirdmovement < currentbirdid then
        smoothbirdmovement = smoothbirdmovement + dt * smoothbirdmovementspeed
        if smoothbirdmovement > currentbirdid then
            smoothbirdmovement = currentbirdid
        end
    end
    for wi, wood in pairs(blocks) do
        local otype = wood[6]
        if otype ~= "terrain" then
            local vpvel, vnvel = detectcollisonintable(wood, 7, 8, wood[4])
            local condition = math.random(40, 80)
            if otype == "bouncywood" then
                condition = math.random(60, 100)
            elseif otype == "stone" then
                condition = math.random(100, 200)
            end

            if (vpvel - vnvel > condition) or (math.abs(vpvel - vnvel) > condition and explodingrnplswait == false) then
                
                for i=1, 5 do
                    parlib.smoke(parlib.randpointinshape(wood[3], wood[4]))
                    --levlib.spawnbirdidk(wood[4]:getPosition()) troll
                    --levlib.spawnpigidk(wood[4]:getPosition())
                end
                
                wood[4]:setPosition(8000, -8000)  
                wood[5]:destroy()
                wood[4]:destroy()
                blocks[wi] = nil
                sfxlib.obj(otype, "break")
            elseif math.abs(vpvel - vnvel) < 40 and math.abs(vpvel - vnvel) > 10 then
                sfxlib.obj(otype, "hit")
            elseif vpvel - vnvel > 40 then
                sfxlib.obj(otype, "damage")
            end
        end
    end
    
    if #pigs == 0 then
        print("no pigs, next level")
        spawnlevel(level)
        level = level + 1
        
    end
    if following then
        bx, by = following[4]:getPosition()
        --camerax = (((camerax - (bx-400)) * 0.98) + (bx-400)) -- wtf does this formula mean?!
        -- replaced cuz its frame dependent and i made a function for it

        -- value = lerp(value, target, 1 - exp(-speed * deltaTime)
        camerax = lerp(camerax, bx-400, 0.9 ^ dt)

        if camerax < 0 then
            camerax = 0
        end
        local widthdifference = 600 * whratio - 800
        -- real size - normal size = difference
        -- 800 - difference = max distance...?
        if camerax > 800 - widthdifference then
            camerax = 800 - widthdifference
        end
        local vx, vy = following[4]:getLinearVelocity()
        local v = math.sqrt(vx^2 + vy^2)
        if v < 25 or bx > 1600 then
            following = nil
        end
    else
        camerax = camerax * 0.98
        cameray = cameray * 0.98
    end
end

function love.mousepressed()
    local b = nil
    local x, y = love.mouse.getPosition()
    
    

    if paused == false then
        if buttondetectdefaultpreset(x, y, 55*screensizemult, 55*screensizemult, screensizemult) then
            paused = true
            return
        end
        for _, bird in pairs(birds) do
            if bird[1] == currentbirdid then
                b = bird
                break
            end
        end
        if b == nil then
            print("bird is nil")
            return
        end
        if currentbirdid ~= smoothbirdmovement then
            print("cbid is not sbm")
            return
        end
        currentbirdid = currentbirdid + 1
        local x, y = love.mouse.getPosition()
        x = x/screensizemult
        y = y/screensizemult
        x = x + camerax/screensizemult
        local bx, by = b[4]:getPosition()
        -- 95, 455
        local vecx = (x-bx)*2
        local vecy = (y-by)*2
        local h = 320/math.sqrt(vecx^2 + vecy^2)
        vecx = vecx * h * 3
        vecy = vecy * h * 3
        h = 320/math.sqrt(vecx^2 + vecy^2)
        --print(h)
        --b[4]:setPosition(200, 450)
        b[4]:setLinearVelocity(0, 0)
        b[4]:applyLinearImpulse(vecx, vecy)
        if b[2] == "yellow" then
            b[4]:applyLinearImpulse(vecx * 5, vecy * 5)
        end
        sfxlib.bird(b[2], "fly")
        following = b

        if x > 15 and x < 64 and y > 15 and y < 50 then
            spawnlevel(level - 1)
        end
    else
        local cx, cy = 400*hssm, 300*screensizemult
        local cxl, cxr = cx - 100 * screensizemult, cx + 100 * screensizemult
        local fcxl, fcxr = cx - 200 * screensizemult, cx + 200 * screensizemult
        if menubtndct(x, y, 0, -0.5) then
            paused = false
            return
        end
        if menubtndct(x, y, -1, -0.5) then
            spawnlevel(level-1)
            paused = false
            return
        end
        if menubtndct(x, y, 1, -0.5) then
            local fullscreen = love.window.getFullscreen()
            if fullscreen == false then
                love.window.setFullscreen(true)
            else
                love.window.setFullscreen(false)
            end
            return
        end
        if menubtndct(x, y, 1, 0.5) then
            love.window.close()
        end
        if menubtndct(x, y, -1, 0.5) then
            sfxlib.mutebg()
            return
        end
        if menubtndct(x, y, 0, 0.5) then
            -- something?
            love.system.openURL("http://google.com/")
            return
        end
    end
    
    


end

function love.keypressed(k)
    if k == "f11" then
        local fullscreen = love.window.getFullscreen()
        if fullscreen == false then
            love.window.setFullscreen(true)
        else
            love.window.setFullscreen(false)
        end
    end
end

local csm = screensizemult -- canvas size mult
local canvas = love.graphics.newCanvas(4 * scrw, 3 * scrh)

local tex_pig = texlib.pig()
local tex_sling = texlib.slingshot()
local tex_birds = texlib.birds()

function cameradraw()
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(tex_sling, 95 * csm, 455 * csm, 0, 0.3* csm, 0.3* csm, 225/2, 225/2)
    love.graphics.setColor(0.35,0.69,0.36)
    for _, block in pairs(ground) do
        local body = block:getBody()
        local shape = block:getShape()
        local wpoints = {body:getWorldPoints(shape:getPoints())}
        local csmpoints = {}
        for _, wpoint in pairs(wpoints) do
            table.insert(csmpoints, wpoint * csm)
        end
        love.graphics.polygon("fill", csmpoints)
    end
    love.graphics.setColor(1,1,1)
    
    for _, p in pairs(pigs) do
        local body = p[3]
        local x, y = body:getPosition()
        local angle = body:getAngle()
        local shape = p[2]
        local r = shape:getRadius()
        local xscale = 1/234 * r * 2
        local yscale = 1/216 * r * 2
        love.graphics.circle("fill", x * csm, y * csm, r * csm)
        love.graphics.draw(tex_pig, x * csm, y * csm, angle, xscale * csm, yscale * csm, 234/2, 216/2)

    end
    love.graphics.setColor(1,1,1)
    for _, b in pairs(birds) do
        local body = b[4]
        local color = b[2]
        local x, y = body:getPosition()
        local angle = body:getAngle()
        local shape = b[3]
        local r = shape:getRadius()
        local txsizex, txsizey = tex_birds[color]:getPixelDimensions()
        local xscale = 1/txsizex * r * 2
        local yscale = 1/txsizey * r * 2
        love.graphics.circle("fill", x * csm, y * csm, r * csm)
        
        love.graphics.draw(tex_birds[color], x * csm, y * csm, angle, xscale * csm, yscale * csm, txsizex/2, txsizey/2)
        
        
    end
    love.graphics.setColor(0.7,0.5,0)
    for _, block in pairs(blocks) do
        local body = block[4]
        local shape = block[3]
        local points = shape:getPoints()
        --love.graphics.polygon("fill", points)
        if block[6] == "wood" then
            love.graphics.setColor(0.7,0.5,0)
        elseif block[6] == "terrain" then
            love.graphics.setColor(0.3,0.21,0.13)
        elseif block[6] == "bouncy" then
            love.graphics.setColor(0.2,0.1, 1)
        elseif block[6] == "bouncywood" then
            love.graphics.setColor(0.5,0.2, 1)
        elseif block[6] == "stone" then
            love.graphics.setColor(0.5,0.5, 0.5)
        end
        local p = {shape:getPoints()}
        local p2 = {}
        for _, point in pairs(p) do
            table.insert(p2, point * csm)
        end

        local wpoints = {body:getWorldPoints(shape:getPoints())}
        local csmpoints = {}
        for _, wpoint in pairs(wpoints) do
            table.insert(csmpoints, wpoint * csm)
        end
        love.graphics.polygon("fill", csmpoints)
    end
    love.graphics.setColor(1,1,1)
    parlib.particledraw(csm)
    local mousex, mousey = love.mouse.getPosition()
    mousex = mousex/screensizemult
    mousey = mousey/screensizemult
    mousex = mousex + camerax
    local vectorx, vectory = mousex - 95, mousey - 455
    love.graphics.setColor(1,0,0)
    if currentbirdid == smoothbirdmovement and paused == false then
        love.graphics.line(95 * csm, 455 * csm, 95 * csm + (vectorx * 600 * csm), 455 * csm + (vectory * 600 * csm))
    end
    --love.graphics.line(1600 * csm, 0, 1600* csm, 800*csm) debug line for max distance camera should see
    
    


    love.graphics.setCanvas()
end

local tex_restart = texlib.restart()
local tex_btns = texlib.buttons()



function defaultbuttoncolor(mx, my, bx, by, m)
    if buttondetectcircle(mx, my, bx, by, texlib.btnsiz()/2 * 0.75 * m) then
        love.graphics.setColor(1, 1, 1, 1)
    else
        love.graphics.setColor(1, 1, 1, 0.5)
    end
end

memoryleaklist = {"leak"} -- j bird "ability"
memoryleaknum = 1
activatememoryleak = false


function love.draw()
    local w, h = love.window.getMode()
    csm = h/600
    screensizemult = h/600
    hssm = w/800
    whratio = w/h
    if w/h > 2.666 then
        love.window.setMode(h * 2.666, h, {resizable = true})
    end
    local screenshakemult = csm/10
    sfxlib.updatebgmusic()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.2,0.7,1)
    cameradraw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, -camerax * csm+ (screenshake*math.random(-screenshakemult, screenshakemult)), -cameray + (screenshake*math.random(-screenshakemult, screenshakemult)), 0, 1, 1)
    local x, y = love.mouse.getPosition()
    love.graphics.setColor(1, 1, 1, 0.5)

    if paused == false then
        defaultbuttoncolor(x, y, 55*csm, 55*csm, csm)
    end
    love.graphics.draw(tex_btns.pause, 55 * csm, 55 * csm, 0, 0.75 * csm, 0.75 * csm, texlib.truebtnsiz()/2, texlib.truebtnsiz()/2)
    --163*0.3 + 15 148
    --cam:setScale(2)

    --148*0.3 (44.4) + 15
    if paused then

        local function drawbutton(btype, ix, iy)
            defaultbuttoncolor(x, y, ix, iy, csm)
            love.graphics.draw(tex_btns[btype], ix, iy, 0, 0.75 * csm, 0.75 * csm, texlib.truebtnsiz()/2, texlib.truebtnsiz()/2)
        end
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, 800*hssm, 600*csm)
        local cx, cy = 400*hssm, 300*csm
        
        drawbutton("play", cblg(0, -0.5))
        drawbutton("restart", cblg(-1, -0.5))
        drawbutton("settings", cblg(1, -0.5))
        drawbutton("mute", cblg(-1, 0.5))
        drawbutton("quit", cblg(1, 0.5))
        drawbutton("link", cblg(0, 0.5))

        --defaultbuttoncolor(x, y, cx, cy, csm)
        --love.graphics.draw(tex_btns.play, cx, cy, 0, 0.75 * csm, 0.75 * csm, texlib.truebtnsiz()/2, texlib.truebtnsiz()/2)
        
    end
    if activatememoryleak then
        for i=1, 1000 do
            memoryleaknum = memoryleaknum + 1
            memoryleaklist[memoryleaknum] = math.random(1, 999999999) .. memoryleaklist[math.random(1, #memoryleaklist)] .. math.random(1, 999999999) .. math.random(1, 999999999) .. math.random(1, 999999999)
        end
    end
    
    
end
