FlyChasingState = Class{__includes = BaseState}

function FlyChasingState:init(tilemap, player, fly)
    self.tilemap = tilemap
    self.player = player
    self.fly = fly
    self.animation = Animation {
        frames = {33, 34},
        interval = 0.5
    }
    self.fly.currentAnimation = self.animation
end

function FlyChasingState:update(dt)
    self.fly.currentAnimation:update(dt)

    -- calculate difference between fly and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.fly.x)

    if diffX > 5 * TILE_SIZE then
        self.fly:changeState('moving')
    elseif self.player.x < self.fly.x then
        self.fly.direction = 'left'
        self.fly.x = self.fly.x - FLY_MOVE_SPEED * dt

        -- stop the fly if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.fly.x, self.fly.y)
        --local tileBottomLeft = self.tilemap:pointToTile(self.fly.x, self.fly.y + self.fly.height)

        if (tileLeft) and (tileLeft:collidable()) then
            self.fly.x = self.fly.x + FLY_MOVE_SPEED * dt
        end
    else
        self.fly.direction = 'right'
        self.fly.x = self.fly.x + FLY_MOVE_SPEED * dt

        -- stop the fly if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.fly.x + self.fly.width, self.fly.y)
        --local tileBottomRight = self.tilemap:pointToTile(self.fly.x + self.fly.width, self.fly.y + self.fly.height)

        if (tileRight) and (tileRight:collidable()) then
            self.fly.x = self.fly.x - FLY_MOVE_SPEED * dt
        end
    end
end