
Powerup = Class{}

function Powerup:init(skin)
    -- intial positions
    self.x = math.random(math.floor(VIRTUAL_WIDTH-5)) -- spawn powerup at y not greather than 432
    self.y = math.random(math.floor(VIRTUAL_HEIGHT / 3)) -- spawn powerup at y not greather than 81

    -- height width of powerups
    self.width = 16
    self.height = 16

    self.skin = skin 

    self.dy = 50
    self.dx = 0
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end
    return true
end


function Powerup:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Powerup:render()
    if self.y <= VIRTUAL_HEIGHT then
        love.graphics.draw(gTextures['main'], gFrames['powerup'][self.skin],
            self.x, self.y)
    end
end
