HelpState = Class{__includes = BaseState}


arrow = love.graphics.newImage('graphics/arrow.png')
space = love.graphics.newImage('graphics/space.png')
esc = love.graphics.newImage('graphics/esc.png')
function HelpState:enter(params)
    self.highScores = params.highScores
end

function HelpState:update(dt)
    -- return to the start screen if we press escape
    if love.keyboard.wasPressed('escape') then
        gSounds['wall-hit']:play()
        
        gStateMachine:change('start', {
            highScores = self.highScores
        })
    end
end


function HelpState:render()
    love.graphics.draw(arrow,40,55)
    love.graphics.draw(space,40,75)
    love.graphics.draw(esc,52,95)

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("HELP",0, 10, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("KEYS",0, 40, 216, 'center')
    love.graphics.printf("POWER UPS AND BRICK",100, 40, 432, 'center')
    love.graphics.printf("moves the paddle",105, 60, 216, 'left')
    love.graphics.printf("pause/unpause game",105, 79, 216, 'left')
    love.graphics.printf("back / exit",105, 99, 216, 'left')
    love.graphics.printf("spawns two extra balls",285, 60, 216, 'left')
    love.graphics.printf("adds extra life",285, 79, 216, 'left')
    love.graphics.printf("locked brick, need key to unlock",285, 99, 216, 'left')
    love.graphics.printf("unlocks locked brick",285, 119, 216, 'left')

    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf("SPACE",55, 79, 216, 'left')
    love.graphics.printf("ESC",60, 99, 216, 'left')
    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.draw(gTextures['main'], gFrames['powerup'][1],250, 55)
    love.graphics.draw(gTextures['main'], gFrames['powerup'][2],250, 75)
    love.graphics.draw(gTextures['main'], gFrames['lock'],242, 95)
    love.graphics.draw(gTextures['main'], gFrames['key'],250, 115)
    


    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("Press Escape to return to the main menu!",
        0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, 'center')
end