--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
    self.player = player

    self.animation = Animation {
        frames = {1},
        interval = 1
    }

    self.player.currentAnimation = self.animation
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
        self.player:changeState('walking')
    end

    if love.keyboard.wasPressed('up') then
        self.player:changeState('jump')
    end
	
	if love.keyboard.wasPressed('down') then
		self.player:changeState('ducking')
	end

    -- check if we've collided with any entities and die if so
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) then
            --gSounds['death']:play()
			if not self.player.invulnerable then
				self.player:damage(1)
				self.player:goInvulnerable(1.5)
		
				if self.player.health == 0 then
					gStateMachine:change('start')
				end
			end
        end
    end
end