SlimeChasingState = Class{__includes = BaseState}

function SlimeChasingState:init(tilemap, player, slime)
    self.tilemap = tilemap
    self.player = player
    self.slime = slime
    self.animation = Animation {
        frames = {1, 2},
        interval = 0.5
    }
    self.slime.currentAnimation = self.animation
end

function SlimeChasingState:update(dt)
    self.slime.currentAnimation:update(dt)

    -- calculate difference between slime and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.slime.x)

    if diffX > 5 * TILE_SIZE then
        self.slime:changeState('moving')
    elseif self.player.x < self.slime.x then
        self.slime.direction = 'left'
        self.slime.x = self.slime.x - SLIME_MOVE_SPEED * dt

        -- stop the slime if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.slime.x, self.slime.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.slime.x, self.slime.y + self.slime.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.slime.x = self.slime.x + SLIME_MOVE_SPEED * dt
        end
    else
        self.slime.direction = 'right'
        self.slime.x = self.slime.x + SLIME_MOVE_SPEED * dt

        -- stop the slime if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.slime.x + self.slime.width, self.slime.y)
        local tileBottomRight = self.tilemap:pointToTile(self.slime.x + self.slime.width, self.slime.y + self.slime.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.slime.x = self.slime.x - SLIME_MOVE_SPEED * dt
        end
    end
end