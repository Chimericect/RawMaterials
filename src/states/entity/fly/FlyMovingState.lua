FlyMovingState = Class{__includes = BaseState}

function FlyMovingState:init(tilemap, player, fly)
    self.tilemap = tilemap
    self.player = player
    self.fly = fly
    self.animation = Animation {
        frames = {33, 34},
        interval = 0.5
    }
    self.fly.currentAnimation = self.animation

    self.movingDirection = math.random(2) == 1 and 'left' or 'right'
    self.fly.direction = self.movingDirection
    self.movingDuration = math.random(5)
    self.movingTimer = 0
end

function FlyMovingState:update(dt)
    self.movingTimer = self.movingTimer + dt
    self.fly.currentAnimation:update(dt)

    -- reset movement direction and timer if timer is above duration
    if self.movingTimer > self.movingDuration then

        -- chance to go into idle state randomly
        if math.random(4) == 1 then
            self.fly:changeState('idle', {

                -- random amount of time for fly to be idle
                wait = math.random(5)
            })
        else
            self.movingDirection = math.random(2) == 1 and 'left' or 'right'
            self.fly.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    elseif self.fly.direction == 'left' then
        self.fly.x = self.fly.x - FLY_MOVE_SPEED * dt

        -- stop the fly if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.fly.x, self.fly.y)
        --local tileBottomLeft = self.tilemap:pointToTile(self.fly.x, self.fly.y + self.fly.height)

        if (tileLeft) and (tileLeft:collidable()) then
            self.fly.x = self.fly.x + FLY_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'right'
            self.fly.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    else
        self.fly.direction = 'right'
        self.fly.x = self.fly.x + FLY_MOVE_SPEED * dt

        -- stop the fly if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.fly.x + self.fly.width, self.fly.y)
        --local tileBottomRight = self.tilemap:pointToTile(self.fly.x + self.fly.width, self.fly.y + self.fly.height)

        if (tileRight) and (tileRight:collidable()) then
            self.fly.x = self.fly.x - FLY_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'left'
            self.fly.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    end

    -- calculate difference between fly and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.fly.x)

    if diffX < 5 * TILE_SIZE then
        self.fly:changeState('chasing')
    end
end