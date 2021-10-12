SlimeIdleState = Class{__includes = BaseState}

function SlimeIdleState:init(tilemap, player, slime)
    self.tilemap = tilemap
    self.player = player
    self.slime = slime
    self.waitTimer = 0
    self.animation = Animation {
        frames = {3},
        interval = 1
    }
    self.slime.currentAnimation = self.animation
end

function SlimeIdleState:enter(params)
    self.waitPeriod = params.wait
end

function SlimeIdleState:update(dt)
    if self.waitTimer < self.waitPeriod then
        self.waitTimer = self.waitTimer + dt
    else
        self.slime:changeState('moving')
    end

    -- calculate difference between slime and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.slime.x)

    if diffX < 5 * TILE_SIZE then
        self.slime:changeState('chasing')
    end
end