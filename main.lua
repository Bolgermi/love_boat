-- Fading on the opening splash
fade_time = 5
fade_timer = 5

canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- Player Object
player = { x = 10, y = 200, speed = 200, img = nil }
isAlive = true
enemy_counter = 100

-- Sound storage
sound = love.audio.newSource("assets/gun.wav", "static")
music = love.audio.newSource("assets/battle_music.mp3","static")
sfx = love.audio.newSource("assets/cheer.mp3","static")

-- Image Storage
bulletImg = nil
enemyImg = nil

-- Entity Storage
bullets = {} 
enemies = {} 

local changeMenu =false


function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- Loading
function love.load(arg)

	player.img = love.graphics.newImage('assets/Cruiser.png')
	enemyImg = love.graphics.newImage('assets/BattleShip.png')
	bulletImg = love.graphics.newImage('assets/bullet.png')

	love.graphics.setFont(love.graphics.newFont(18))
  	image = love.graphics.newImage('assets/titlescreen.png')
  	background = love.graphics.newImage('assets/background.jpg')
end

function love.keyreleased(key)
    if key=="return"  then
        changeMenu = true
    end 
end

-- Updating
function love.update(dt)

	if love.keyboard.isDown('escape') then
		love.event.quit()
	end

	-- Time out how far apart shots can be.
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	-- Time out enemy creation
	createEnemyTimer = createEnemyTimer - (1 * dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		-- Randomised enemy creation
		randomNumber = math.random(10, love.graphics.getHeight() - 10)
		newEnemy = { x = love.graphics.getWidth() + 10, y = randomNumber, img = enemyImg }
		table.insert(enemies, newEnemy)
	end


	-- Updates the positions of bullets
	for i, bullet in ipairs(bullets) do
		bullet.x = bullet.x + (350 * dt)

		if bullet.x > love.graphics.getWidth() + 10 then -- remove bullets when they pass off the screen
			table.remove(bullets, i)
		end
	end

	-- Updates enemy position
	for i, enemy in ipairs(enemies) do
		enemy.x = enemy.x - (600 * dt)
		if enemy_counter < 50 then
			enemy.x = enemy.x - (700 * dt)
			if enemy_counter < 20 then
				enemy.x = enemy.x - (1000 * dt)
			end
		end

		-- Removes enemies when they exit the screen
		if enemy.x < 0 then
			table.remove(enemies, i)
		end
	end

	-- Collision detection
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				if enemy_counter > 0 then
					enemy_counter = enemy_counter - 1
				end
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
		and isAlive then
			table.remove(enemies, i)
			isAlive = false
		end
	end


	if love.keyboard.isDown('left','a') then
		if player.x > 0 then -- binds you to the map
			player.x = player.x - (player.speed*dt)
		end
	elseif love.keyboard.isDown('right','d') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed*dt)
		end
	elseif love.keyboard.isDown('up','w') then
		if player.y > 0 then
			player.y = player.y - (player.speed*dt)
		end
	elseif love.keyboard.isDown('down','z')	then
		if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
			player.y = player.y + (player.speed*dt)
		end
	end

	if love.keyboard.isDown('space', 'rctrl', 'lctrl', 'ctrl') and canShoot then
		-- Plays the background music
		sound:play()
		-- Create some bullets
		newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
		table.insert(bullets, newBullet)
		canShoot = false
		canShootTimer = canShootTimerMax
	end

	if not isAlive and love.keyboard.isDown('r') then
		-- Removes all bullets and enemies from screen if reset
		bullets = {}
		enemies = {}

		-- Resets timers
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax

		-- Moves player back to default position
		player.x = 10
		player.y = 200

		-- Resets game state
		enemy_counter = 100
		isAlive = true
	end
end


function love.draw(dt)
	love.graphics.draw(image)
	love.graphics.print('Press Enter to start',love.graphics:getWidth()/2-80, love.graphics:getHeight()-30)
	sfx:play()
	if changeMenu then
			love.graphics.draw(background)
			sfx:stop()
			music:play()

			for i, bullet in ipairs(bullets) do
				love.graphics.draw(bullet.img, bullet.x, bullet.y)
			end

			for i, enemy in ipairs(enemies) do
				love.graphics.draw(enemy.img, enemy.x, enemy.y)
			end

			love.graphics.setColor(255, 255, 255)
			love.graphics.print("Enemies Remaining: " .. tostring(enemy_counter), 400, 10)

			if isAlive then
				love.graphics.draw(player.img, player.x, player.y)
			else
				love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
			end

			if debug then
				fps = tostring(love.timer.getFPS())
				love.graphics.print("Current FPS: "..fps, 9, 10)
			end

			if enemy_counter == 0 then
					love.graphics.print([[Congratulations, you won!]], love.graphics:getWidth()/2-250, love.graphics:getHeight()/2-50)
				enemy_counter = 0
			end
	end

end







