-- 3 player scoreboard script for Super Street Fighter 2 Turbo on mame-rr
-- (c) 2013 Pau Oliva Fora

count_scores = 1

score_pau = 0
score_manel = 0
score_ernest = 0

matches_pau = 0
matches_manel = 0
matches_ernest = 0

p1_sets_won = 0
p2_sets_won = 0
prev_p1_sets_won = 0
prev_p2_sets_won = 0

p1 = ""
p2 = ""

p1_char = 0
p2_char = 0

p1_color = 0
p2_color = 0

is_match_active = 0
prev_is_match_active = 0

local function draw_scores()

	local date = os.date("%d/%m/%Y")

	local mode = "Tournament"
	if not count_scores then
		mode = "Practice"
	end

	gui.text (79,216, date .. " " .. mode .. " - Ernest: " .. score_ernest .. "/" .. matches_ernest .. " Manel: " .. score_manel .. "/" .. matches_manel .. " Pau: " .. score_pau .. "/" .. matches_pau )

	if not count_scores then
		return
	end

	-- do nothing if playing against the CPU
	if (p1 == "" or p2 == "") then
		return
	end

	-- do nothing if playing against yourself
	if (p1 == p2) then
		return
	end

	local winner = who_wins()

	local update = 0

	if (winner == 1) then
		if (p1 == "Manel") then
			score_manel=score_manel+1
			update=1
		end
		if (p1 == "Ernest") then
			score_ernest=score_ernest+1
			update=1
		end
		if (p1 == "Pau") then
			score_pau=score_pau+1
			update=1
		end
	elseif (winner == 2) then
		if (p2 == "Manel") then 
			score_manel=score_manel+1
			update=1
		end
		if (p2 == "Ernest") then
			score_ernest=score_ernest+1
			update=1
		end
		if (p2 == "Pau") then
			score_pau=score_pau+1
			update=1
		end
	end

	if (update==1) then
		if (p1=="Ernest") then matches_ernest=matches_ernest+1 end
		if (p1=="Manel") then matches_manel=matches_manel+1 end
		if (p1=="Pau") then matches_pau=matches_pau+1 end
		if (p2=="Ernest") then matches_ernest=matches_ernest+1 end
		if (p2=="Manel") then matches_manel=matches_manel+1 end
		if (p2=="Pau") then matches_pau=matches_pau+1 end
		update=0
		p1=""
		p2=""
	end

	return
end

local function check_players()

	if not count_scores then
		gui.text(0,0,"")
		return
	end

	prev_is_match_active = is_match_active
	is_match_active = memory.readbyte(0xFF844E)

	-- only do this once, to avoid bugs when everything is set to 0 at the end of the match, but the match is still active
	if (prev_is_match_active == 0 and is_match_active == 1) then
		p1_char = memory.readbyte(0xFF87DF)
		p1_color = memory.readbyte(0xFF87FF)
		p2_color = memory.readbyte(0xFF8BFF)
		p2_char = memory.readbyte(0xFF8BDF)
	end

	if not(is_match_active == 1) then -- if not in match
		gui.text(0,0,"")
		return
	end

	if memory.readword(0xFF847F) == 0 then --if not in match
		gui.text(0,0,"")
		return
	end


	if (p1_char == 0 and p2_char == 0 and p1_color == 0 and p2_color == 0) then
		-- this is to avoid overwriting the player when the match ends
		-- but the 'is_match_active' value is not yet 0
		-- however this has a side efect: no names if both p1 & p2 use LP ryu (which can't be done without cheats).
		gui.text(0,0,"")
		p1=""
		p2=""
		return
	end

	if (p1_char == 0x09) then
		gui.text(33,45,"Manel") --sagat
		p1 = "Manel"
	end
	if (p1_char == 0x02) then
		gui.text(33,45,"Ernest") -- blanka
		p1 = "Ernest"
	end
	if (p1_char == 0x04) then
		gui.text(33,45,"Ernest") -- ken
		p1 = "Ernest"
	end
	if (p1_char == 0x00) and (p1_color == 0x00) then
		gui.text(33,45,"Pau") -- Ryu
		p1 = "Pau"
	end

	if (p2_char == 0x09) then
		gui.text(331,45,"Manel") --sagat
		p2 = "Manel"
	end
	if (p2_char == 0x02) then
		gui.text(327,45,"Ernest") -- blanka
		p2 = "Ernest"
	end
	if (p2_char == 0x04) then
		gui.text(327,45,"Ernest") -- ken
		p2 = "Ernest"
	end
	if (p2_char == 0x00) and (p2_color == 0x00) then
		gui.text(339,45,"Pau") -- Ryu
		p2 = "Pau"
	end

	return
end

function who_wins()

	prev_p1_sets_won = p1_sets_won
	prev_p2_sets_won = p2_sets_won

	p1_sets_won = memory.readbyte(0xFF87DE)
	p2_sets_won = memory.readbyte(0xFF8BDE)

	if (p1_sets_won==0 and p2_sets_won==0) then

		if (prev_p1_sets_won > prev_p2_sets_won) then
			return 1
		end
		if (prev_p2_sets_won > prev_p1_sets_won) then
			return 2
		end

	end

	return 0
end


input.registerhotkey(1, function()
	count_scores = not count_scores
	print((count_scores and "Tournament" or "Practice") .. " mode")
end)


print("Super Turbo Scoreboard Script (c) 2013 pof")
print("------------------------------------------")
print("Lua Hotkey 1: Torunament/Practice mode")


-- Main loop
while true do
	-- Draw these functions on the same frame data is read
	gui.register(function()
		check_players()	
		draw_scores()	
	end)

	--Pause the script until the next frame
	emu.frameadvance()
end
