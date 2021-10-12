--[[
    GD50
    Super Mario Bros. Remake

    -- PlayState Class --
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.camX = 0
    self.camY = 0
    self.level = LevelMaker.generate(100, 10)
    self.tileMap = self.level.tileMap
    self.background = math.random(3)
    self.backgroundX = 0

    self.gravityOn = true
    self.gravityAmount = 6

    self.player = Player({
        x = 0, y = 0,
        width = 16, height = 20,
        texture = 'green-alien',
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end,
			['ducking'] = function() return PlayerDuckState(self.player) end
        },
        map = self.tileMap,
        level = self.level,
		health = 6
    })

    self:spawnEnemies()

    self.player:changeState('falling')
end

function PlayState:enter(params)
	self.player.score = params.score
	--self.tileMap.width = params.width
end

function PlayState:update(dt)
    Timer.update(dt)

    -- remove any nils from pickups, etc.
    self.level:clear()

    -- update player and level
    self.player:update(dt)
    self.level:update(dt)
    self:updateCamera()

    -- constrain player X no matter which state
    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end
end

function PlayState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['background4b'], gFrames['background4b'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['background4b'], gFrames['background4b'][self.background], math.floor(-self.backgroundX),
        gTextures['background4b']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['background4b'], gFrames['background4b'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['background4b'], gFrames['background4b'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['background4b']:getHeight() / 3 * 2, 0, 1, -1)
    
    -- translate the entire view of the scene to emulate a camera
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    
    self.level:render()

    self.player:render()
    love.graphics.pop()
	
	if self.player.hasKey then
		love.graphics.draw(gTextures['keys_and_locks'], gFrames['keys_and_locks'][1], 3, 20)
	end
    
    -- render score
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(self.player.score), 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(self.player.score), 4, 4)
	
	local healthLeft = self.player.health
    local heartFrame = 1

    for i = 1, 3 do
        if healthLeft > 1 then
            heartFrame = 5
        elseif healthLeft == 1 then
            heartFrame = 3
        else
            heartFrame = 1
        end

        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][heartFrame],
           180 + (i * 16), 5)
        
        healthLeft = healthLeft - 2
    end
end

function PlayState:updateCamera()
    -- clamp movement of the camera's X between 0 and the map bounds - virtual width,
    -- setting it half the screen to the left of the player so they are in the center
    self.camX = math.max(0,
        math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

    -- adjust background X to move a third the rate of the camera for parallax
    self.backgroundX = (self.camX / 3) % 256
end

--[[
    Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
    -- spawn snails in the level
    for x = 1, self.tileMap.width do

        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    -- random chance, 1 in 20
                    if math.random(10) == 1 then
						-- instantiate snail, declaring in advance so we can pass it into state machine
						if math.random(3) == 1 then
							local snail
							snail = Snail {
								texture = 'creatures',
								x = (x - 1) * TILE_SIZE,
								y = (y - 2) * TILE_SIZE + 2,
								width = 16,
								height = 16,
								stateMachine = StateMachine {
									['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
									['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
									['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
								}
							}
							snail:changeState('idle', {
								wait = math.random(5)
							})

							table.insert(self.level.entities, snail)
						elseif math.random(3) == 2 then
							local fly
							fly = Fly {
								texture = 'creatures',
								x = (x - 1) * TILE_SIZE,
								y = (y - 3) * TILE_SIZE + 2,
								width = 16,
								height = 16,
								stateMachine = StateMachine {
									['idle'] = function() return FlyIdleState(self.tileMap, self.player, fly) end,
									['moving'] = function() return FlyMovingState(self.tileMap, self.player, fly) end,
									['chasing'] = function() return FlyChasingState(self.tileMap, self.player, fly) end
								}
							}
							fly:changeState('idle', {
								wait = math.random(5)
							})
	
							table.insert(self.level.entities, fly)
						else
							local slime
							slime = Slime {
								texture = 'creatures',
								x = (x - 1) * TILE_SIZE,
								y = (y - 2) * TILE_SIZE + 2,
								width = 16,
								height = 16,
								stateMachine = StateMachine {
									['idle'] = function() return SlimeIdleState(self.tileMap, self.player, slime) end,
									['moving'] = function() return SlimeMovingState(self.tileMap, self.player, slime) end,
									['chasing'] = function() return SlimeChasingState(self.tileMap, self.player, slime) end
								}
							}
							slime:changeState('idle', {
								wait = math.random(5)
							})
	
							table.insert(self.level.entities, slime)
						end
					end
                end
            end
        end
    end
end