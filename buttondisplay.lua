buttons = {}

function buttons.add( new_sprite, start_x, start_y, new_rot)
	table.insert(buttons, {sprite = new_sprite, x = start_x, y = start_y, rot = new_rot})
end

function buttons.getcount()
	
	return table.getn(buttons)
end


function buttons.update(delta, pps, fade_start)
	for i, b in ipairs(buttons) do
		if b.y < -64 then
			table.remove(buttons, i)
		else
			b.y = b.y - (pps * delta)
		end

		if b.y < fade_start and b.y >= 0 then -- simple fade
			b.alpha = b.y * (256 / fade_start)
		end
	end
end

function draw_button(sprite, pos_x, pos_y, rot, draw_alpha)
	-- as the rotation  rotates around the origin, we must compensate.
	-- the entire purpose of this program is to draw arrows and buttons,
	--  the rotation flags are relevant to the specific sprite used.

	local offset_x = 0
	local offset_y = 0
	local rotation = 0

	if rot == "down" or rot == "" then
		-- no change, it's the base image
	elseif rot == "up" then
		offset_x = 64
		offset_y = 64
		rotation = math.pi
	elseif rot == "left" then
		offset_x = 64
		offset_y = 0
		rotation = math.pi/2
	elseif rot == "right" then
		offset_x = 0
		offset_y = 64
		rotation = 3 * math.pi / 2
	end
	if draw_alpha then
		love.graphics.setColor(255,255,255, draw_alpha)
	end
	sprite:draw(pos_x + offset_x, pos_y + offset_y, rotation)
	love.graphics.setColor(255,255,255,255) -- reset to prevent magic fade
end
