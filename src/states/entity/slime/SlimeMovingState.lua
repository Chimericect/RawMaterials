--[[
    GD50
    Super Mario Bros. Remake

    -- slimeMovingState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

SlimeMovingState = Class{__includes = BaseState}

function SlimeMovingState:init(tilemap, player, slime)
    self.tilemap = tilemap
    self.player = player
    self.slime = slime
    self.animation = Animation {
        frames = {1, 2},
        interval = 0.5
    }
    self.slime.currentAnimation = self.animation

    self.movingDirection = math.random(2) == 1 and 'left' or 'right'
    self.slime.direction = self.movingDirection
    self.movingDuration = math.random(5)
    self.movingTimer = 0
end

function SlimeMovingState:update(dt)
    self.movingTimer = self.movingTimer + dt
    self.slime.currentAnimation:update(dt)

    -- reset movement direction and timer if timer is above duration
    if self.movingTimer > self.movingDuration then

        -- chance to go into idle state randomly
        if math.random(4) == 1 then
            self.slime:changeState('idle', {

                -- random amount of time for slime to be idle
                wait = math.random(5)
            })
        else
            self.movingDirection = math.random(2) == 1 and 'left' or 'right'
            self.slime.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    elseif self.slime.direction == 'left' then
        self.slime.x = self.slime.x - SLIME_MOVE_SPEED * dt

        -- stop the slime if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.slime.x, self.slime.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.slime.x, self.slime.y + self.slime.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.slime.x = self.slime.x + SLIME_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'right'
            self.slime.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    else
        self.slime.direction = 'right'
        self.slime.x = self.slime.x + SLIME_MOVE_SPEED * dt

        -- stop the slime if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.slime.x + self.slime.width, self.slime.y)
        local tileBottomRight = self.tilemap:pointToTile(self.slime.x + self.slime.width, self.slime.y + self.slime.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.slime.x = self.slime.x - SLIME_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'left'
            self.slime.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    end

    -- calculate difference between slime and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.slime.x)

    if diffX < 5 * TILE_SIZE then
        self.slime:changeState('chasing')
    end
end