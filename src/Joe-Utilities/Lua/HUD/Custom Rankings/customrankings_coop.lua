//
-- SRB2 and SRB2Kart's HU_DrawTabRankings with some heavy edits to fit the server
-- Ported and edited by Jaden

-- Editors note: Compact scoreboard supports up to 30 players, too lazy!!!
//

local cv_cooplives = CV_FindVar("cooplives")

// self-explanatory.
local function V_DrawPlayerHighlight(v, player, x, y, scale)
	local patches = {}

	for i = 0, 8 do
		local buffer = string.format("BIG_HIGH%s", i + 1)
		patches[i] = v.cachePatch(buffer)
	end

	if (player == consoleplayer) then
		v.drawScaled(x << FRACBITS, y << FRACBITS, scale, patches[(leveltime / 4) % 8])
	end
end

// sort the players on the scoreboard or else, this will be chaos!!!!!!
local function M_SortPlayers(scorelines)
	if (gametyperules & GTR_RACE) then
		table.sort(scorelines, function(a, b)
			if (circuitmap) then
				return (a.laps > b.laps)
			else
				return (a.realtime < b.realtime)
			end
		end)
	elseif (gametyperules & GTR_FRIENDLY) then
		table.sort(scorelines, function(a, b) 
			return (a.score > b.score)
		end)
	end
end

// as the function says, this is for coop.
local M_DrawCoopRankings = function(v, scorelines)
	local x = 40
	local y = 32

	local rightoffset = 240
	local dupadjust = v.width()/v.dupx()
	local duptweak = (dupadjust - 320)/2

	v.fadeScreen(0xFF00, 16) -- do some nice fade so it wont be confusing to see.

	v.drawFill(1 - duptweak,  26, dupadjust - 2, 1, 0) // Draw a horizontal line because it looks nice!
	v.drawFill(1 - duptweak, 182, dupadjust - 2, 1, 0) // And a horizontal line near the bottom.

	if (#scorelines > 9) then
		v.drawFill(160, 26, 1, 156, 0) // Draw a vertical line to separate the two sides.
		rightoffset = 160 - 4 - x
	end

	M_SortPlayers(scorelines)

	local aligntype_left = (#scorelines > 9 and "thin" or "left")
	local aligntype_right = (#scorelines > 9 and "thin-right" or "right")

	--for i = 1, #scorelines do
	for i, player in ipairs(scorelines) do
		local player_name = JoeBase.GetPlayerName(player, true, false)
		local flags = 0

		// everything should be translucent if you are either dead, an spectator or out of the netgame with rejointimeout enabled
		if (player.playerstate == PST_DEAD) or (player.spectator) or (player.quittime > 0) then flags = $ | V_50TRANS end

		//
		// Information
		//

		-- player name
		if (not player.quittime or (leveltime / (TICRATE/2) & 1)) then
			local nsub = (#scorelines > 9) and 12 or 19

			local result = string.sub(player_name, 1, nsub)

			v.drawString(x + 20, y, result, flags|V_ALLOWLOWERCASE|V_6WIDTHSPACE, aligntype_left)
		end

		-- player lives
		if G_GametypeUsesLives() then
			if cv_cooplives.value ~= 0 then
				v.drawString(x - 1, y + 5, min(99, player.lives), flags, "thin-right")
			end 
		end

		-- skin icon
		if (player.realmo.color) then			
			local colormap = (player.realmo.colorized and TC_RAINBOW or player.skin)
			local scale = FRACUNIT/2

			local back = v.cachePatch("STLIVEBK")
			local character = v.getSprite2Patch(player.skin, "XTRA", (player.powers[pw_super] and true or false), 0)
			
			v.drawScaled(x*FRACUNIT, (y - 4)*FRACUNIT, FRACUNIT/2, back, 0)
			v.drawScaled(x*FRACUNIT, (y - 4)*FRACUNIT, scale, character, flags, v.getColormap(colormap, player.realmo.color))
		
			-- where are you?
			V_DrawPlayerHighlight(v, player, x, y-4, FRACUNIT/2)
		end

		-- gametype things
		if (gametyperules & GTR_RACE) then -- are we on a race?
			local colormap = (player.exiting and V_GREENMAP or 0)

			if (circuitmap) then
				if (player.exiting) then
					v.drawString(x + rightoffset, y, "FIN", colormap|V_6WIDTHSPACE, aligntype_right)
				else
					v.drawString(x + rightoffset, y, string.format("Lap %d", player.laps+1), hilicol|V_ALLOWLOWERCASE|V_6WIDTHSPACE, aligntype_right)
				end
			else
				v.drawString(x + rightoffset, y, JoeRankings.DoTimer(player.realtime, true), colormap|V_6WIDTHSPACE, aligntype_right)
			end

		elseif (gametyperules & GTR_FRIENDLY) then -- are we on a coop netgame?
			if player.spectator then
				-- died epicly
				v.drawString(x + rightoffset, y, "Spec", V_SKYMAP|V_6WIDTHSPACE|flags, aligntype_right)
			
			elseif player.timeover then
				-- youre too slow!
				v.drawString(x + rightoffset, y, "No Contest", V_REDMAP|V_6WIDTHSPACE, "thin-right")
			
			else
				-- your score
				v.drawString(x + rightoffset, y, player.score, flags|V_6WIDTHSPACE, aligntype_right)
			end
		end

		//
		// Icons
		//

		local ico_offsety = (cv_cooplives.value == 0) and y or y-4
		local finished = (player.pflags & PF_FINISHED) and not player.afk

		-- are you a spectator? draw a icon.
		if (player.spectator) then
			JoeRankings.DoIcons(v, x - 11, ico_offsety, 0, "spec")
			
		-- are you afk? do it again.
		elseif (player.afk) then
			JoeRankings.DoIcons(v, x - 11, ico_offsety, flags, "afk")
		
		-- did you finish? draw a icon too.
		elseif finished and not G_IsSpecialStage() then
			JoeRankings.DoIcons(v, x - 11, ico_offsety, flags, "finish")
		end

		-- draw everyones ping!
		JoeRankings.drawPing(v, player, x-30, y)

		// offset this, NOW!
		y = $ + 17
		if (i == 9) then
			x = 200
			y = 32
		end
	end

	------------------------------
	-- 		 Misc related       --
	------------------------------

	JoeRankings.Coop_CacheStuff(v, scorelines) -- lol
end

// This is a copy pasta of the function above :vv
local M_DrawCompactCoopRankings = function(v, scorelines)	
	local x = 24
	local y = 33
	
	local rightoffset = 0
	local dupadjust = v.width()/v.dupx()
	local duptweak = (dupadjust - 320)/2

	v.fadeScreen(0xFF00, 16) -- do some nice fade so it wont be confusing to see.

	v.drawFill(1 - duptweak,  26, dupadjust - 2, 1, 0) // Draw a horizontal line because it looks nice!
	v.drawFill(1 - duptweak, 182, dupadjust - 2, 1, 0) // And a horizontal line near the bottom.
	v.drawFill(160, 26, 1, 156, 0) // Draw a vertical line to separate the two sides.

	rightoffset = 160 - 4 - x

	M_SortPlayers(scorelines)

	--for i = 1, #scorelines do
	for i, player in ipairs(scorelines) do
		local player_name = JoeBase.GetPlayerName(player, true, false)
		local flags = 0

		// everything should be translucent if you are either dead, an spectator or out of the netgame with rejointimeout enabled
		if (player.playerstate == PST_DEAD) or (player.spectator) or (player.quittime > 0) then flags = $ | V_50TRANS end

		//
		// Information
		//

		-- player name
		if (not player.quittime or (leveltime / (TICRATE/2) & 1)) then
			local result = string.sub(player_name, 1, 15)

			v.drawString(x + 18, y - 2, result, flags|V_ALLOWLOWERCASE|V_6WIDTHSPACE, "thin")
		end

		-- player lives
		if G_GametypeUsesLives() then
			if cv_cooplives.value ~= 0 then
				v.drawString(x + 3, y, min(99, player.lives), flags, "thin-right")
			end 
		end
	
		-- skin icon
		if (player.realmo.color) then			
			local colormap = (player.realmo.colorized and TC_RAINBOW or player.skin)
			local scale = FRACUNIT/3
			
			local character = v.getSprite2Patch(player.skin, "XTRA", (player.powers[pw_super] and true or false), 0)

			v.drawScaled((x + 4)*FRACUNIT, (y - 4)*FRACUNIT, scale, character, flags, v.getColormap(colormap, player.realmo.color))
		
			-- where are you?
			V_DrawPlayerHighlight(v, player, x+4, y-4, FRACUNIT/3)
		end

		-- gametype things
		if (gametyperules & GTR_RACE) then -- are we on a race?
			local colormap = (player.exiting and V_GREENMAP or 0)
			
			if (circuitmap) then
				if (player.exiting) then
					v.drawString(x + rightoffset, y - 2, "FIN", colormap|V_6WIDTHSPACE, "thin-right")
				else
					v.drawString(x + rightoffset, y - 2, string.format("Lap %d", player.laps+1), hilicol|V_ALLOWLOWERCASE|V_6WIDTHSPACE, "thin-right")
				end
			else
				v.drawString(x + rightoffset, y - 2, JoeRankings.DoTimer(player.realtime, true), colormap|V_6WIDTHSPACE, "thin-right")
			end

		elseif (gametyperules & GTR_FRIENDLY) then -- are we on a coop netgame?
			if player.spectator then
				-- died epicly
				v.drawString(x + rightoffset, y - 2, "Spec", V_SKYMAP|V_6WIDTHSPACE|flags, "thin-right")
			
			elseif player.timeover then
				-- youre too slow!
				v.drawString(x + rightoffset, y - 2, "No Contest", V_REDMAP|V_6WIDTHSPACE, "thin-right")
			
			else
				-- your score
				v.drawString(x + rightoffset, y - 2, player.score, flags|V_6WIDTHSPACE, "thin-right")
			end
		end

		//
		// Icons
		//

		-- only draw it when cooplives is set to Infinite, since there isnt any space.
		if cv_cooplives.value == 0 then
			local finished = (player.pflags & PF_FINISHED) and not player.afk

			-- are you a spectator? draw a icon.
			if (player.spectator) then
				JoeRankings.DoIcons(v, x - 6, y - 2, 0, "spec")
				
			-- are you afk? do it again.
			elseif (player.afk) then
				JoeRankings.DoIcons(v, x - 6, y - 2, flags, "afk")
			
			-- did you finish? draw a icon too.
			elseif finished and not G_IsSpecialStage() then
				JoeRankings.DoIcons(v, x - 6, y - 2, flags, "finish")
			end
		end

		-- draw everyones ping!
		JoeRankings.drawPing(v, player, x - 20, y - 3)

		// you know the drill.
		y = $ + 10
		if (i == 15) then
			x = 184
			y = 33
		end
	end

	------------------------------
	-- 		 Misc related       --
	------------------------------

	JoeRankings.Coop_CacheStuff(v, scorelines) -- lol
end

rawset(_G, "M_DrawCoopOverlay", function(v, scorelines)
	if (#scorelines > 18) or CV_FindVar("compactscoreboard").value then
		M_DrawCompactCoopRankings(v, scorelines)
	else
		M_DrawCoopRankings(v, scorelines)
	end
end)