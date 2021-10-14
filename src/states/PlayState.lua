--[[
    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]

-- powerup variables
local powerupTime = 20
local powerupTime2 = 50
local keyTime = 30
local powerupTimeInterval = 30
local powerupTimeInterval2 = 70
local keyTimeInterval = 40


function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level
    hasKey = false
    self.recoverPoints = 5000

    self.exPaddlePoints = 1000
    

    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end


    if powerupTime >= powerupTimeInterval and (not self.powerup1) and #ballList < 2 and self.health > 0 then
        self.powerup1 = Powerup(1)
    end

    if powerupTime2 >= powerupTimeInterval2 and (not self.powerup2) and self.health < 3 then
        self.powerup2 = Powerup(2)
    end

 
    if hasLockedBrick and not hasKey and (not self.key) then
        if keyTime >= keyTimeInterval then
            self.key = Key()
        end
    end

    if self.key then
        self.key:update(dt)
        if self.key:collides(self.paddle) then
            self.key = nil
            hasKey = true
        end
    end
    keyTime = keyTime + dt
    powerupTime = powerupTime + dt
    powerupTime2 = powerupTime2 + dt
    if self.powerup1  then
            self.powerup1:update(dt)
            if self.powerup1:collides(self.paddle) then
                self.powerup1 = nil

                if self.ball then
                    print("selfball")
                    extraBall1 = Ball(4)
                    extraBall1.x = self.paddle.x + (self.paddle.width / 2) - 4
                    extraBall1.y = self.paddle.y - 8
                    extraBall1.dx = math.random(-200, 200)
                    extraBall1.dy = math.random(-50, -60)

                    extraBall2 = Ball(4)
                    extraBall2.x = self.paddle.x + (self.paddle.width / 2) - 4
                    extraBall2.y = self.paddle.y - 8
                    extraBall2.dx = math.random(-200, 200)
                    extraBall2.dy = math.random(-50, -60)
                elseif extraBall1 then
                    print("eB1")
                    self.ball = Ball(4)
                    self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
                    self.ball.y = self.paddle.y - 8
                    self.ball.dx = math.random(-200, 200)
                    self.ball.dy = math.random(-50, -60)

                    extraBall2 = Ball(4)
                    extraBall2.x = self.paddle.x + (self.paddle.width / 2) - 4
                    extraBall2.y = self.paddle.y - 8
                    extraBall2.dx = math.random(-200, 200)
                    extraBall2.dy = math.random(-50, -60)
                elseif extraBall2 then
                    print("eB2")
                    extraBall1 = Ball(4)
                    extraBall1.x = self.paddle.x + (self.paddle.width / 2) - 4
                    extraBall1.y = self.paddle.y - 8
                    extraBall1.dx = math.random(-200, 200)
                    extraBall1.dy = math.random(-50, -60)

                    self.ball = Ball(4)
                    self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
                    self.ball.y = self.paddle.y - 8
                    self.ball.dx = math.random(-200, 200)
                    self.ball.dy = math.random(-50, -60)
                end
            end

    end

    if self.powerup2 then
        self.powerup2:update(dt)
        if self.powerup2:collides(self.paddle) then
            self.powerup2 = nil
            self.health = self.health + 1
        end
    end
  

    ballList = {}
    if extraBall1 then
        if extraBall1.y < VIRTUAL_HEIGHT then
            extraBall1:update(dt)
            table.insert(ballList, extraBall1)
        elseif extraBall1.y > VIRTUAL_HEIGHT then
            extraBall1 = nil
        end
    end

    if extraBall2 then
        if extraBall2.y < VIRTUAL_HEIGHT then
            extraBall2:update(dt)
            table.insert(ballList, extraBall2)
        elseif extraBall2.y > VIRTUAL_HEIGHT then
            extraBall2 = nil
        end
    end


    self.paddle:update(dt)


    if self.ball then
        if self.ball.y < VIRTUAL_HEIGHT then
            self.ball:update(dt)
            table.insert(ballList, self.ball)
        elseif self.ball.y > VIRTUAL_HEIGHT then
            self.ball = nil
        end
    end



    -- if ball goes below bounds, revert to serve state and decrease health
    if #ballList == 0 then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health > 0 then
            self.paddle.size = math.max(self.paddle.size-1, 1)

        end
        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    for k, bb in pairs(ballList) do

        if bb:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            bb.y = self.paddle.y - 8
            bb.dy = -bb.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if bb.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                bb.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - bb.x))

            -- else if we hit the paddle on its right side while moving right...
            elseif bb.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                bb.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - bb.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do
            -- only check collision if we're in play
            if brick.inPlay and bb:collides(brick) then
                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- if we have enough points, extend paddle
                if self.score > self.exPaddlePoints then
                    self.paddle.size = math.min(4, self.paddle.size + 1)
                    self.exPaddlePoints = math.min(100000, 
                            self.exPaddlePoints * 2)
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    extraBall1 = nil
                    extraBall2 = nil
                    self.ball = nil

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = Ball(math.random(7)),
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if bb.x + 2 < brick.x and bb.dx > 0 then

                    -- flip x velocity and reset position outside of brick
                    bb.dx = -bb.dx
                    bb.x = brick.x - 8

                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif bb.x + 6 > brick.x + brick.width and bb.dx < 0 then

                    -- flip x velocity and reset position outside of brick
                    bb.dx = -bb.dx
                    bb.x = brick.x + 32

                -- top edge if no X collisions, always check
                elseif bb.y < brick.y then

                    -- flip y velocity and reset position outside of brick
                    bb.dy = -bb.dy
                    bb.y = brick.y - 8

                -- bottom edge if no X collisions or top collision, last possibility
                else

                    -- flip y velocity and reset position outside of brick
                    bb.dy = -bb.dy
                    bb.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(bb.dy) < 150 then
                    bb.dy = bb.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()
    love.graphics.draw(gTextures['background'], 
        -- draw at coordinates 0, 0
        0, 0, 
        -- no rotation
        0,
        -- scale factors on X and Y axis so it fills the screen
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    if self.ball then
        self.ball:render()
    end

    if self.powerup1 then
        if self.powerup1.y <= VIRTUAL_WIDTH then
            self.powerup1:render()
        else
            self.powerup1 = nil
            powerupTime = 0
        end
    end

    if self.powerup2 then
        if self.powerup2.y <= VIRTUAL_WIDTH then
            self.powerup2:render()
        else
            self.powerup2 = nil
            powerupTime2 = 3
        end
    end

--------------------------------------------------------------------------------
    if self.key then
        if self.key.y <= VIRTUAL_WIDTH then
            self.key:render()
        else
            self.key = nil
            keyTime = 0
        end
    end

    if extraBall1 then
        extraBall1:render()
    end

    if extraBall2 then
        extraBall2:render()
    end

    renderScore(self.score)
    renderHealth(self.health)
    renderLevel(self.level)

    if hasKey and hasLockedBrick then
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("You can now unlock locked bricks!", 0, VIRTUAL_HEIGHT - 10, VIRTUAL_WIDTH, 'center')
    else if hasLockedBrick then
            love.graphics.setFont(gFonts['small'])
            love.graphics.printf("Oh no! A locked brick. Acquire a key!", 0, VIRTUAL_HEIGHT - 10, VIRTUAL_WIDTH, 'center') 
        end
    end
    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
    

    
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end
