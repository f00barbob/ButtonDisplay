
local mouse_was_down = false
local accumulate = 0
local window_height = 321
local window_width = 224

local auto = false
local animated = true
local scrolling = true

local debugme = false

require("AnAL")
require("buttondisplay")


local canvas_height = window_height * 2
local canvas_width = window_width * 2

local fade_start = 128 -- with respect to canvas size
local scroll_rate = 600
local anim_rate = .2

local anim_rate_mult = 1
local last_anim_rate_mult= 1

function love.load()
	-- we draw on a large canvas and scale it by 1/2 later on
	cnv_buttons = love.graphics.newCanvas(canvas_width, canvas_height )
	love.window.setMode(window_width, window_height, {vsync=false})
	love.window.setTitle("RNGDispTest")

	-- load the images
	img_arrow = love.graphics.newImage("arrow.png")
	img_btn_a = love.graphics.newImage("btn_a.png")
	img_btn_b = love.graphics.newImage("btn_b.png")
	img_btn_start = love.graphics.newImage("btn_start.png")

	-- AnALyze them
	anm_arrow = newAnimation(img_arrow,64,64,anim_rate,0)
	anm_btn_a = newAnimation(img_btn_a,64,64,anim_rate,0)
	anm_btn_b = newAnimation(img_btn_b,64,64,anim_rate,0)
	anm_btn_start = newAnimation(img_btn_start,64,64,anim_rate,0)

	-- spawn the netthread
	print("spawning networking thread")
	netthread = love.thread.newThread("netthread.lua")
	netchannel = love.thread.getChannel("netchan")
	netthread:start()
	inbound = {}
end

function love.update(dt)
	accumulate = accumulate + dt
	if accumulate  > .04 then
		if auto and scrolling then
			do_randy(math.random(1,7))
		end
		accumulate = 0
	end
	

	-- update the sprite animations
	if animated then
		anm_arrow:update(dt)
		anm_btn_a:update(dt)
		anm_btn_b:update(dt)
		anm_btn_start:update(dt)
	end

	-- update the sprites' locations, dt parameter, pixels/s on the canvas
	if scrolling then
		buttons.update(dt, scroll_rate, fade_start) 
	end

--	if love.mouse.isDown("l") == true and mouse_was_down == false then
	--spam one sprite per left click
--		mouse_was_down = true 
--		auto = not auto
	if love.mouse.isDown("r") == true then
--	 --vomit sprites so long as right button is held
		do_randy(math.random(7))
--	elseif love.mouse.isDown("l") == false then
--		mouse_was_down = false -- mouse released
	end



	netmsg =  netchannel:pop()
	if netmsg then
		do_randy(tonumber(netmsg))
		table.insert(inbound, v)
	end
end

function love.keypressed(key)
	if 	key == "a" then
	 animated = not animated
	elseif key == "q" then
	 auto = not auto
	elseif 	key == "s" then
	 scrolling = not scrolling
	elseif 	key == "d" then
	 debugme = not debugme
	elseif  key == "p" then
	 anim_rate_mult = anim_rate_mult + .1
	elseif 	key == "o" then
	 anim_rate_mult = anim_rate_mult - .1
	 if anim_rate_mult <= .1 then anim_rate_mult = .1 end
	elseif 	key == "\\" then
	 anim_rate_mult = 1
	end

	if anim_rate_mult ~= last_anim_rate_mult then
		last_anim_rate_mult = anim_rate_mult
		anm_arrow:setSpeed(anim_rate_mult)
		anm_btn_a:setSpeed(anim_rate_mult)
		anm_btn_b:setSpeed(anim_rate_mult)
		anm_btn_start:setSpeed(anim_rate_mult)
	end


end


function love.draw()
	-- draw the button display to its canvas
	love.graphics.setCanvas(cnv_buttons)
	render_button_display()
	-- reset to framebuffer
	love.graphics.setCanvas()
	-- draw the button canvas on framebuffer
	love.graphics.draw(cnv_buttons, 0, 0, 0, .5, .5)
	-- print the currect button sprite count
	if debugme then	draw_debug() end
end



function love.threaderror(thread, errortext)
    error(errortext) -- Makes sure any errors that happen in the thread are displayed onscreen.
end






function draw_debug()
	love.graphics.print("sprites\t" .. buttons.getcount(),20,200)
	love.graphics.print("anim speed\t" .. anim_rate_mult)
end

function do_randy(randy)
	--local randy = arg[0] or 999
  print("hi randy!" .. randy)
	-- i'm feeling randy, baby
	spawn_y = canvas_height
	--local randy = math.random(1,7)
	if randy == 0 then
		buttons.add(anm_arrow, 0, spawn_y, "left")
	elseif randy == 1 then
		buttons.add(anm_arrow, 64,spawn_y, "down")
	elseif randy == 2 then
		buttons.add(anm_arrow, 128,spawn_y, "up")
	elseif randy == 3 then
		buttons.add(anm_arrow, 192, spawn_y, "right")
	elseif randy == 4 then
		buttons.add(anm_btn_a, 256,spawn_y)
	elseif randy == 5 then
		buttons.add(anm_btn_b, 320, spawn_y)
	elseif randy == 6 then
		buttons.add(anm_btn_start, 384, spawn_y)
	end
end



function render_button_display()
	cnv_buttons:clear()
	for i, b in ipairs(buttons) do
		draw_button(b.sprite, b.x, b.y, b.rot, b.alpha)
	end
end





