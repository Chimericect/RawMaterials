FlyIdleState = Class{__includes = BaseState}

function FlyIdleState:init(tilemap, player, fly)
    self.tilemap = tilemap
    self.player = player
    self.fly = fly
    self.waitTimer = 0
    self.animation = Animation {
        frames = {35},
        interval = 1
    }
    self.fly.currentAnimation = self.animation
end

function FlyIdleState:enter(params)
    self.waitPeriod = params.wait
end

function FlyIdleState:update(dt)
    if self.waitTimer < self.waitPeriod then
        self.waitTimer = self.waitTimer + dt
    else
        self.fly:changeState('moving')
    end

    -- calculate difference between fly and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.fly.x)

    if diffX < 5 * TILE_SIZE then
        self.fly:changeState('chasing')
    end
end