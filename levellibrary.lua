local ll = {}

function ll.ground()
    local grshp = love.physics.newRectangleShape(8000, 100)
    local grbody = love.physics.newBody(world, 400, 550, "static")
    local grfix = love.physics.newFixture(grbody, grshp, 1)
    grfix:setFriction(1)
    local grshp2 = love.physics.newRectangleShape(8000, 400)
    local grbody2 = love.physics.newBody(world, 700, 750, "static")
    local grfix2 = love.physics.newFixture(grbody2, grshp2, 1)
    grbody2:setAngle(-0.3)
    grfix:setFriction(0.1)
    table.insert(ground, grfix)
    table.insert(ground, grfix2)
end

function ll.decode(level)
    for _, object in pairs(level) do
        
        local otype, x, y, sx, sy = object[1], object[2], object[3], object[4], object[5]
        --print("ot: " .. otype .. ", x: " .. x .. ", y: " .. y .. ", sx: " .. sx .. ", sy: " .. sy)
        if otype == "pig" then
            local pshape = love.physics.newCircleShape(sx)
            local pbody = love.physics.newBody(world, x, y, "dynamic")
            local pfix = love.physics.newFixture(pbody, pshape, 1)
            pfix:setFriction(0.7)
            local newentry = {sx, pshape, pbody, pfix}
            table.insert(pigs, newentry)
        end
        if otype == "wood" then
            local pshape = love.physics.newRectangleShape(sx, sy)
            local pbody = love.physics.newBody(world, x, y, "dynamic")
            local pfix = love.physics.newFixture(pbody, pshape, 1)
            pfix:setFriction(0.7)
            pfix:setRestitution(0.02)
            local newentry = {sx, sy, pshape, pbody, pfix, otype}
            table.insert(blocks, newentry)
        end
        if otype == "stone" then
            local pshape = love.physics.newRectangleShape(sx, sy)
            local pbody = love.physics.newBody(world, x, y, "dynamic")
            local pfix = love.physics.newFixture(pbody, pshape, 1)
            pfix:setFriction(0.9)
            pfix:setDensity(10)
            pfix:setRestitution(0.01)
            local newentry = {sx, sy, pshape, pbody, pfix, otype}
            table.insert(blocks, newentry)
        end
        if otype == "terrain" then
            local pshape = love.physics.newRectangleShape(sx, sy)
            local pbody = love.physics.newBody(world, x, y, "static")
            local pfix = love.physics.newFixture(pbody, pshape, 1)
            pfix:setFriction(0.7)
            pfix:setRestitution(0.2)
            local newentry = {sx, sy, pshape, pbody, pfix, otype}
            table.insert(blocks, newentry)
        end
        if otype == "bouncy" then
            local pshape = love.physics.newRectangleShape(sx, sy)
            local pbody = love.physics.newBody(world, x, y, "static")
            local pfix = love.physics.newFixture(pbody, pshape, 1)
            pfix:setFriction(0.7)
            pfix:setRestitution(1.8)
            
            local newentry = {sx, sy, pshape, pbody, pfix, otype}
            table.insert(blocks, newentry)
        end
        if otype == "bouncywood" then
            local pshape = love.physics.newRectangleShape(sx, sy)
            local pbody = love.physics.newBody(world, x, y, "dynamic")
            local pfix = love.physics.newFixture(pbody, pshape, 1)
            pfix:setFriction(0)
            pfix:setRestitution(1.8)
            pfix:setDensity(5)
            local newentry = {sx, sy, pshape, pbody, pfix, otype}
            table.insert(blocks, newentry)
        end
        if otype == "birds" then
            for i, bird in pairs(object) do
                if i ~= 1 and bird ~= "" then
                    local size, density = 0, 0
                    if bird == "red" then
                        size = 25
                        density = 3
                    elseif bird == "yellow" then
                        size = 20
                        density = 10
                    elseif bird == "black" then
                        size = 30
                        density = 0.01
                    elseif bird == "j" then
                        size = 25
                        density = 3
                    end
                    local pshape = love.physics.newCircleShape(size)
                    local pbody = love.physics.newBody(world, 30, 400, "dynamic")
                    local pfix = love.physics.newFixture(pbody, pshape, 1)
                    pfix:setFriction(0.7)
                    pfix:setDensity(density)
                    pfix:setRestitution(0.2)
                    local newentry = {i-1, bird, pshape, pbody, pfix}
                    table.insert(birds, newentry)
                end
                
            end
        end
    end
end
function ll.spawnbirdidk(x,y)
    local size, density = 0, 0
    
    size = 25
    density = 3
    
    local pshape = love.physics.newCircleShape(size)
    local pbody = love.physics.newBody(world, x, y, "dynamic")
    local pfix = love.physics.newFixture(pbody, pshape, 1)
    pfix:setFriction(0.7)
    pfix:setDensity(density)
    local newentry = {-9, "red", pshape, pbody, pfix}
    table.insert(birds, newentry)
end
function ll.spawnpigidk(x,y)
    local size, density = 0, 0
    
    size = 25

    local pshape = love.physics.newCircleShape(size)
    local pbody = love.physics.newBody(world, x, y, "dynamic")
    local pfix = love.physics.newFixture(pbody, pshape, 1)
    pfix:setFriction(0.7)
    local newentry = {sx, pshape, pbody, pfix}
    table.insert(pigs, newentry)
end

return ll