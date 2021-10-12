--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = 18
    local topperset = 37

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
		--never spawn on an empty space
			if math.random(7) == 1 and x > 3 and x < width - 3 then
				for y = 7, height do
					table.insert(tiles[y],
						Tile(x, y, tileID, nil, tileset, topperset))
				end
			else
				tileID = TILE_ID_GROUND

				-- height at which we would spawn a potential jump block
				local blockHeight = 4
	
				for y = 7, height do
					table.insert(tiles[y],
						Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
				end

				-- chance to generate a pillar
				if math.random(8) == 1 then
					blockHeight = 2
                
					-- chance to generate bush on pillar
					if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'crystals',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = math.random(3),
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
				-- chance to generate bushes
				elseif math.random(8) == 1 then
					table.insert(objects,
						GameObject {
							texture = 'crystals',
							x = (x - 1) * TILE_SIZE,
							y = (6 - 1) * TILE_SIZE,
							width = 16,
							height = 16,
							frame = math.random(3),
							collidable = false
						}
					)
				end

				-- chance to spawn a block
				if math.random(10) == 1 then
					table.insert(objects,

						-- jump block
						GameObject {
							texture = 'crates',
							x = (x - 1) * TILE_SIZE,
							y = (blockHeight - 1) * TILE_SIZE,
							width = 16,
							height = 16,

							-- make it a random variant
							frame = math.random(4),
							collidable = true,
							hit = false,
							solid = true,

							-- collision function takes itself
							onCollide = function(obj)

								-- spawn a gem if we haven't already hit the block
								if not obj.hit then

									-- chance to spawn gem, not guaranteed
									if math.random(5) == 1 then

										-- maintain reference so we can set it to nil
										local gem = GameObject {
											texture = 'gems',
											x = (x - 1) * TILE_SIZE,
											y = (blockHeight - 1) * TILE_SIZE - 4,
											width = 16,
											height = 16,
											frame = math.random(#GEMS),
											collidable = true,
											consumable = true,
											solid = false,

											-- gem has its own function to add to the player's score
											onConsume = function(player, object)
												gSounds['pickup']:play()
												player.score = player.score + 100
											end
										}
										
										-- make the gem move up from the block and play a sound
										Timer.tween(0.1, {
											[gem] = {y = (blockHeight - 2) * TILE_SIZE}
										})
										gSounds['powerup-reveal']:play()

										table.insert(objects, gem)
									end

									obj.hit = true
								end

								gSounds['empty-block']:play()
							end
						}
					)
				end
		end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
	spawnLockedBlock(objects, width)
    
    return GameLevel(entities, objects, map)
end

function spawnLockedBlock(objects, width)
	local ranBlock = math.random(#objects)
	while objects[ranBlock].texture ~= 'crates' do
		ranBlock = math.random(#objects)
	end
	local color = math.random(#LOCKS)
	local block = GameObject {
		texture = 'keys_and_locks',
		x = objects[ranBlock].x,
		y = objects[ranBlock].y,
		width = 16,
		height = 16,
		
		frame = LOCKS[color],
		collidable = false,
		hit = false,
		solid = true,
		onCollide = function(obj, player)
			if player.hasKey then
				for k, object in pairs(objects) do
					if object.texture == 'keys_and_locks' then
						table.remove(objects, k)
					end
				end
				player.hasKey = false
				spawnFinish(objects, width)
			end
		end
	}
	
	objects[ranBlock] = block
	local ranBlockKey = math.random(#objects)
	while objects[ranBlockKey].texture == 'keys_and_locks' do
		ranBlockKey = math.random(#objects)
	end
	
	local blockKey = GameObject {
		texture = 'keys_and_locks',
		x = objects[ranBlockKey].x,
		y = objects[ranBlockKey].y,
		width = 16,
		height = 16,
		frame = KEYS[color],
		collidable = true,
		consumable = true,
		solid = false,
		
		onConsume = function(player, object)
			gSounds['pickup']:play()
			player.hasKey = true
		end
	}
	
	objects[ranBlockKey] = blockKey
end

function spawnFinish(objects, gameWidth)
	local ladder_top = GameObject {
		texture = 'ladders',
		x = (gameWidth - 3) * TILE_SIZE,
		y = TILE_SIZE,
		width = 16,
		height = 16,
		frame = 1,
		collidable = false,
		consumable = false,
		solid = false
	}
	table.insert(objects, ladder_top)
	for i = 2, 5 do
		
		local ladder = GameObject {
			texture = 'ladders',
			x = (gameWidth - 3) * TILE_SIZE,
			y = i * TILE_SIZE,
			width = 16,
			height = 16,
			frame = 8,
			collidable = false,
			consumable = true,
			solid = false,
			hit = false,
				onConsume = function(player, object)
				gStateMachine:change('play', {
				score = player.score,
				--width = gameWidth * 2
			})
			end
		}
		table.insert(objects, ladder)
	end
	
	
end
		

