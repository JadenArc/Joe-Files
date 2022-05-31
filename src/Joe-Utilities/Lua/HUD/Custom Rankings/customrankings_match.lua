//
-- M_DrawCompactCoopRankings but made for the purpose of Match, Tag, etc...
-- By Jaden

-- This was pain.
//

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

// simple.
local function M_SortTeams(a, b)
	return (a.score > b.score)
end

local M_DrawMatchRankings = function(v, scorelines)
	local x = 19
	local y = 33
	
	local rightoffset = 0
	local dupadjust = v.width()/v.dupx()
	local duptweak = (dupadjust - 320)/2

	v.fadeScreen(0xFF00, 18) -- do some nice fade so it wont be confusing to see.

	v.drawFill(1 - duptweak,  26, dupadjust - 2, 1, 0) // Draw a horizontal line because it looks nice!
	v.drawFill(1 - duptweak, 182, dupadjust - 2, 1, 0) // And a horizontal line near the bottom.
	v.drawFill(160, 26, 1, 156, 0) // Draw a vertical line to separate the two sides.

	rightoffset = 160 - 18 - x

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

			v.drawString(x + 14, y - 2, result, flags|V_ALLOWLOWERCASE|V_6WIDTHSPACE, "thin")
		end

		-- skin icon
		if (player.realmo.color) then			
			local colormap = (player.realmo.colorized and TC_RAINBOW or player.skin)
			local scale = FRACUNIT/3
			
			local character = v.getSprite2Patch(player.skin, "XTRA", (player.powers[pw_super] and true or false), 0)

			v.drawScaled(x*FRACUNIT, (y - 4)*FRACUNIT, scale, character, flags, v.getColormap(colormap, player.realmo.color))
		
			V_DrawPlayerHighlight(v, player, x, y-4, FRACUNIT/3)
		end

		-- score (ugh...)
		v.drawString(x + rightoffset, y - 2, player.score, flags|V_6WIDTHSPACE, "thin-right")

		//
		// Icons
		//

		-- draw your ping!
		JoeRankings.drawPing(v, player, x - 14, y - 3)

		-- You are it!
		if (player.pflags & PF_TAGIT) then
			JoeRankings.DoIcons(v, (x + 4) + rightoffset, y - 3, flags, "it")
		end

		y = $ + 10
		if (i == 15) then
			x = 180
			y = 33
		end
	end

	JoeRankings.Match_CacheStuff(v) -- xddd
end

local M_DrawTeamRankings = function(v, scorelines)
	local x = 19
	local y = 33

	local x_red = x + 160
	local x_blue = x
	
	local rightoffset = 0
	local dupadjust = v.width()/v.dupx()
	local duptweak = (dupadjust - 320)/2

	v.fadeScreen(0xFF00, 18) -- do some nice fade so it wont be confusing to see.

	v.drawFill(1 - duptweak,  26, dupadjust - 2, 1, 0) // Draw a horizontal line because it looks nice!
	v.drawFill(1 - duptweak, 182, dupadjust - 2, 1, 0) // And a horizontal line near the bottom.
	v.drawFill(160, 26, 1, 156, 0) // Draw a vertical line to separate the two sides.

	rightoffset = 160 - 17 - x

	local red_team = {}
	local blue_team = {}

	// sort the teams, in a simple way.
	for i, player in ipairs(scorelines) do
		-- red team,
		if (player.ctfteam == 1) then
			table.insert(red_team, player)
	
		-- and blue team.
		elseif (player.ctfteam == 2) then
			table.insert(blue_team, player)
		end
	end

	table.sort(red_team, M_SortTeams)
	table.sort(blue_team, M_SortTeams)

	// Red Team drawing!
	for i, player in ipairs(red_team) do
		-- 16 players, on a limited 15 scoreboard, doesnt fit.
		if (i > 15) then continue end

		// colors!
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

			v.drawString(x_red + 14, y - 2, result, flags|V_ALLOWLOWERCASE|V_6WIDTHSPACE, "thin")
		end

		-- skin icon
		if (player.realmo.color) then			
			local colormap = (player.realmo.colorized and TC_RAINBOW or player.skin)
			local scale = FRACUNIT/3
			
			local character = v.getSprite2Patch(player.skin, "XTRA", (player.powers[pw_super] and true or false), 0)

			v.drawScaled(x_red*FRACUNIT, (y - 4)*FRACUNIT, scale, character, flags, v.getColormap(colormap, player.realmo.color))
		
			V_DrawPlayerHighlight(v, player, x_red, y-4, FRACUNIT/3)
		end

		-- score, yeah.
		v.drawString(x_red + rightoffset, y - 2, player.score, flags|V_6WIDTHSPACE, "thin-right")

		//
		// Icons
		//

		-- draw everyones ping!
		JoeRankings.drawPing(v, player, x_red - 14, y - 3)

		local x1 = (x_red + 4) + rightoffset
		if (player.gotflag & GF_BLUEFLAG) then
			-- if we are on a flag battle (or something), draw the flag that you got.
			JoeRankings.DoIcons(v, x1, y - 3, flags, "flag", skincolor_blueteam)
		end

		y = $ + 10
	end

	-- reset this, now.
	y = 33

	// Blue Team, its your turn.
	for i, player in ipairs(blue_team) do
		if (i > 15) then continue end

		// colors!
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

			v.drawString(x_blue + 14, y - 2, result, flags|V_ALLOWLOWERCASE|V_6WIDTHSPACE, "thin")
		end

		-- skin icon
		if (player.realmo.color) then			
			local colormap = (player.realmo.colorized and TC_RAINBOW or player.skin)
			local scale = FRACUNIT/3
			
			local character = v.getSprite2Patch(player.skin, "XTRA", (player.powers[pw_super] and true or false), 0)

			v.drawScaled(x_blue*FRACUNIT, (y - 4)*FRACUNIT, scale, character, flags, v.getColormap(colormap, player.realmo.color))
		
			V_DrawPlayerHighlight(v, player, x_blue, y-4, FRACUNIT/3)
		end

		-- score, yeah.
		v.drawString(x_blue + rightoffset, y - 2, player.score, flags|V_6WIDTHSPACE, "thin-right")

		//
		// Icons
		//

		-- draw everyones ping!
		JoeRankings.drawPing(v, player, x_blue - 14, y - 3)

		local x1 = (x_blue + 4) + rightoffset
		if (player.gotflag & GF_REDFLAG) then
			-- if we are on a flag battle (or something), draw the flag that you got.
			JoeRankings.DoIcons(v, x1, y - 3, flags, "flag", skincolor_redteam)
		end

		y = $ + 10
	end
	
	JoeRankings.Match_CacheStuff(v) -- xddd
end

rawset(_G, "M_DrawMatchOverlay", function(v, scorelines)
	if G_GametypeHasTeams() then
		M_DrawTeamRankings(v, scorelines)
	else
		M_DrawMatchRankings(v, scorelines)
	end
end)