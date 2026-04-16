local parlib = {}
local particles = {} 
-- {p, p, p, p, {x, y, velx, vely, gravityx, gravityy, size, rotation, phase, {tick, timetochange}, particletype}, p, p, ...}
local particledata = {
    {"smoke", {"smoke1", 1, "smoke2", 0.7, "smoke3", 0.4}},
    {"poof", {"smoke3", 0.4, "smoke2", 0.7, "smoke1", 1}},
    {"explosion", {"darksmoke1", 5, "darksmoke2", 4, "darksmoke3", 3}}
} 
-- {name, {image1, scale1, image2, scale2}, other idk}

for _, particle in pairs(particledata) do
    local imageset = particle[2]
    for i, data in pairs(imageset) do
        if i % 2 == 1 then
            local img = love.graphics.newImage("textures/particle/" .. data .. ".png")
            imageset[i] = img
        end
    end
    particle[2] = imageset
end

function parlib.clearall()
    particles = {}
end

function parlib.particlestep(dt)
    for i, particle in pairs(particles) do
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        particle.vx = particle.vx + particle.mx * dt
        particle.vy = particle.vy + particle.my * dt
        particle.tick = particle.tick + dt
        particle.rotation = particle.rotation + particle.rotationvelocity * dt
        particle.phase = 1 + math.floor(particle.tick / particle.tickchangephase)

        local pdata = nil
        for _, ptype in pairs(particledata) do
            if ptype[1] == particle.type then
                pdata = ptype
            end
        end

        if particle.phase * 2 > #pdata[2] then
            -- todo: delete particle
            particles[i] = nil
        end
    end
end
function parlib.particledraw(csm)
    for _, particle in pairs(particles) do
        local t = particle.type
        local pdata = nil
        for _, ptype in pairs(particledata) do
            if ptype[1] == t then
                pdata = ptype
            end
        end
        
        love.graphics.draw(pdata[2][particle.phase *2 -1], particle.x * csm, particle.y * csm, particle.rotation, pdata[2][particle.phase * 2] * particle.size * csm, pdata[2][particle.phase * 2] * particle.size * csm, 64, 64)
    end
end
function parlib.base(x, y, t, vx, vy, mx, my, size, tickrate, rot, rotvel)
    local newsmoke = {}
    newsmoke.x = x
    newsmoke.y = y
    newsmoke.vx = vx
    newsmoke.vy = vy
    newsmoke.mx = mx
    newsmoke.my = my
    newsmoke.size = size
    newsmoke.phase = 1
    newsmoke.tick = 0
    newsmoke.tickchangephase = math.random(50, 150) * 0.01 * tickrate
    newsmoke.rotation = rot
    newsmoke.rotationvelocity = rotvel
    newsmoke.type = t
    table.insert(particles, newsmoke)
end
function parlib.smoke(x, y)
    parlib.base(x, y, "smoke", math.random(-32, 32), math.random(-32, 32), 0, -10, math.random(7, 13) * 0.02, 1, 0, math.random(-15, 15))
end
function parlib.poof(x, y)
    parlib.base(x, y, "smoke", math.random(-2, 2), math.random(-2, 2), 0, 0, math.random(7, 13) * 0.08, 0.3, math.random(-360, 360), math.random(-3, 3))
end
function parlib.boom(x, y)
    parlib.base(x, y, "explosion", math.random(-32, 32), math.random(-32, 32), 0, -10, math.random(7, 13) * 0.02, 2, math.random(0, 360), 0)
end

function parlib.randpointinshape(shape, body)
    local bx, by = body:getPosition()
    local r2 = body:getAngle()
    local x1, y1, x2, y2, x3, y3, x4, y4 = body:getWorldPoints(shape:getPoints())
    local left, right = math.min(x1, x2, x3, x4), math.max(x1, x2, x3, x4)
    local top, bottom = math.min(y1, y2, y3, y4), math.max(y1, y2, y3, y4)
    local nx, ny = math.random(left, right), math.random(top, bottom)
    local i = 0
    while shape:testPoint(bx, by, r2, nx, ny) == false and i < 30 do
        nx, ny = math.random(left, right), math.random(top, bottom)
        i = i + 1
    end
    return nx, ny
end




return parlib