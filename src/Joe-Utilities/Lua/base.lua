// Some caching

// dont rawset everything, make a table for it
rawset(_G, "JoeBase", {})

// 
--
-- Definitions 
--
//

// Custom Emblem thing
JoeBase.MP_EmblemsTotal = 0
JoeBase.MP_EmblemsGot = 0

// Get the players name, with colors!
JoeBase.GetPlayerName = function(player, perms, stats) -- 2 booleans? wow!!!!!!!!!
	-- you cant guess what is this...
	local function ColorToString(color)
		if (not color) or (color == nil) then return "\x80" end

		local textcolor = (color - V_MAGENTAMAP) >> 12
		return string.char(textcolor + 129)
	end

	perms = $ or false
	stats = $ or false
	
	//
	// Prefixes.
	//

	local player_color = skincolors[player.skincolor].chatcolor
	local player_color_op = skincolors[ColorOpposite(player.skincolor)].chatcolor

	local permissions = ""
	local status = ""

	-- Server permissions.
	if (perms) then
		-- Are you the server? 
		if (player == server) then 
			permissions = ColorToString(player_color_op) .. "~"
		
		-- Or an admin?
		elseif IsPlayerAdmin(player) then 
			permissions = ColorToString(player_color_op) .. "@" 
		end
	end

	-- Spectator, Teams, or IT status. (only on levels, so we can prevent errors.)
	if (stats) and (gamestate == GS_LEVEL) then
		if (player.spectator) then
			status = "\x86[SPEC] "
		end

		if G_GametypeHasTeams() then
			-- Red,
			if (player.ctfteam == 1) then
				status = "\x85[Red] "
			
			-- and Blue.
			elseif (player.ctfteam == 2) then
				status = "\x84[Blue] "
			end
		end

		if (player.pflags & PF_TAGIT) then
			status = "\x87[IT] "
		end
	end

	local result = ColorToString(player_color) or "\x80"

	-- name and color
	return status .. permissions .. result .. player.name
end

-- shortcut.
JoeBase.IsValid = function(mo)
	return (mo and mo.valid)
end

-- another shortcut.
JoeBase.IsServerOrAdmin = function(player)
	return ((player == server) or server) or IsPlayerAdmin(player)
end

-- b.
JoeBase.GetCountdownLogic = function(timer)	
	local tics, timelimitintics, downwards
	local cv_hidetime = CV_FindVar("hidetime")
	
	-- start drawing the time!
	
	// first off, timer logic
	if (timelimit > 0) then timelimitintics = timelimit * (60 * TICRATE) end

	if ((gametyperules & GTR_STARTCOUNTDOWN) and (cv_hidetime and cv_hidetime.value) and (timer <= (cv_hidetime.value*TICRATE))) then
		tics = (cv_hidetime.value*TICRATE - timer) + (TICRATE-1) -- match the race num
		downwards = true
	else
		-- Time limit?
		if ((gametyperules & GTR_TIMELIMIT) and timelimit) then
			if (timelimitintics > timer) then
				tics = (timelimitintics - timer) + (TICRATE-1) -- match the race num
			
			-- Overtime!
			else
				tics = 0
			end
			downwards = true
		else
			tics = timer
			downwards = false
		end
	end
	
	return tics, downwards
end

/*
Might use this in the future...

JoeBase.DrawColorramp = function(v, x, y, width, height, color, flags)
	flags = $ or 0
	color = $ or SKINCOLOR_WHITE

	local colorramp = skincolors[color].ramp
	local ramp_height = height / #colorramp

	for i = 0, (#colorramp - 1) do
		v.drawFill(x, y + (ramp_height * i), width, ramp_height, colorramp[i]|flags)
	end
end
*/

//
-- 
-- CustomRankings Definitions 
--
//

// another table :v
rawset(_G, "JoeRankings", {})

-- from SRB2Kart's hu_stuff.c
JoeRankings.drawPing = function(v, player, x, y)
	-- if (player == server) then return end

	local ping = player.cmd.latency -- sadly, player.ping doesnt exist, unlike kart.
	local gfxnum = 4
	
	if (ping <= 3) then -- excellent
		gfxnum = 0
	elseif (ping <= 6) then -- good
		gfxnum = 1
	elseif (ping <= 9) then -- kinda
		gfxnum = 2
	elseif (ping > 9) then -- bad
		gfxnum = 3
	end 

	if (player.quittime > 0) then -- brazil which means you arent with us anymore
		gfxnum = 4
	end

	local patch = v.cachePatch("PING_" .. gfxnum)
	v.draw(x, y, patch, 0, nil)
end

-- Do a timer.
JoeRankings.DoTimer = function(total, cent)
	if (total == nil or total >= 999999) then 
		return "N/A"
	end

	local result = ""
	
	local pad = "%02d"
	local centiseconds = string.format(pad, G_TicsToCentiseconds(total))
	local seconds = string.format(pad, G_TicsToSeconds(total))
	local minutes = G_TicsToMinutes(total, true)

	if cent then
		result = minutes .. ":" .. seconds .. "." .. centiseconds
	else
		result = minutes .. ":" .. seconds
	end

	return result
end

-- Icons!
JoeRankings.DoIcons = function(v, x, y, flags, type, color)
	local fin_ico = "FINISH_ICO"
	local spec_ico = "SPEC_ICO"
	local flag_ico = "FLAG_ICO"
	local team_ico = "TEAM_ICO"
	local it_ico = "IT_ICO"
	
	local afk_ico = "AFK_ICO" .. tostring(((leveltime % TICRATE)*235)/1000)

	local patch

	if (type == "finish") then patch = fin_ico
	elseif (type == "spec") then patch = spec_ico
	elseif (type == "afk") then patch = afk_ico
	elseif (type == "flag") then patch = flag_ico
	elseif (type == "teams") then patch = team_ico
	elseif (type == "it") then patch = it_ico
	end

	color = $ or SKINCOLOR_WHITE
	
	v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(patch), flags, v.getColormap(TC_DEFAULT, color))
end

// draw the current spectators on the game!
local offset = 0
local J_SpectatorTicker = function(v)
	local text = ""
	local length = 0

	local basewidth = v.width() / v.dupx() -- hmm...

	local spec_table = {}
	for player in players.iterate do
		if player.spectator then
			table.insert(spec_table, player)
		end
	end

	if (#spec_table > 0) then
		for i, player in pairs(spec_table) do
			local k = (i == #spec_table) and "" or "   "
				
			text = $ + player.name .. k
			length = v.stringWidth(text)
		end
						
		offset = $ + 1	
		if (offset >= (basewidth + length)) then
			offset = 0
		end
			
		v.drawString(basewidth - offset, 189, text, V_ALLOWLOWERCASE|V_50TRANS)

	else
		v.drawString(160, 190, "No one's spectating!", V_ALLOWLOWERCASE, "thin-center")
	end
end

-- Basic stuff.
JoeRankings.Coop_CacheStuff = function(v, t1)
	//
	-- how many players are on the server? and whats the limit?
	//
	local plr_str = string.format("[%d - %d] %s", #t1, CV_FindVar("maxplayers").value, CV_FindVar("servername").string) 
	v.drawString(160, 188, plr_str, V_ALLOWLOWERCASE, "thin-center")

	//
	-- emerald amount
	//
	for i = 0, 6 do
		local flags = V_60TRANS
		local patch = v.cachePatch("TEMER" .. (i + 1))
		local x = 6 + (10 * i)
		
		if (emeralds & (EMERALD1 << i)) then flags = 0 end
		v.draw(x, 9, patch, V_SNAPTOLEFT|flags)
	end

	//
	-- emblem amount (disaster, but it works)
	//
	local emb_str = min(JoeBase.MP_EmblemsTotal, JoeBase.MP_EmblemsGot) .. "/" .. JoeBase.MP_EmblemsTotal
	local emb_patch = v.getSpritePatch(SPR_EMBM, H)

	local x, y = 302, 16
	
	if JoeBase.MP_EmblemsTotal ~= 0 then
		v.drawScaled(x*FRACUNIT, (y+5)*FRACUNIT, FRACUNIT/2, emb_patch, V_SNAPTORIGHT, v.getColormap(TC_DEFAULT, SKINCOLOR_MINT))
		v.drawString(x - 18, y - 6, emb_str, V_SNAPTORIGHT, "thin-right")
	else
		v.drawScaled(x*FRACUNIT, (y+5)*FRACUNIT, FRACUNIT/2, emb_patch, V_SNAPTORIGHT, v.getColormap(TC_RAINBOW, SKINCOLOR_JET))
		v.drawString(x - 18, y - 6, "No emblems?", V_SNAPTORIGHT|V_ALLOWLOWERCASE, "thin-right")
	end
end

JoeRankings.Match_CacheStuff = function(v)
	//
	-- A Timer, which also flashes.
	//

	local tics, downwards = JoeBase.GetCountdownLogic(leveltime)

	local flash = (downwards and (tics < 30*TICRATE) and (leveltime/5 & 1)) -- overtime?
	local color = (flash) and "\x85" or "\x82"

	if pointlimit then
		local str_points = string.format("\x82%s: \x80%d", "Point Limit", pointlimit)

		v.drawString(6, 13, str_points, V_SNAPTOLEFT|V_ALLOWLOWERCASE, "left")
	end

	local str_time = string.format(color .. "%s: \x80%s", (downwards) and "Time Left" or "Time Elapsed", JoeRankings.DoTimer(tics, false))
	local y = (pointlimit) and 5 or 8

	v.drawString(6, y, str_time, V_ALLOWLOWERCASE|V_SNAPTOLEFT, "left")

	//
	-- Team Scores
	//

	local function getplural(val)
		return (val == 1) and "" or "s"
	end

	if G_GametypeHasTeams() then
		local x = 308
		local flags = 0

		local diff_ico = (gametyperules & GTR_TEAMFLAGS) and "flag" or "teams"
		local diff_str = (gametyperules & GTR_TEAMFLAGS) and "Flag" or "Point"

		local str_r = string.format("%u %s%s.", redscore, diff_str, getplural(redscore))
		local str_b = string.format("%u %s%s.", bluescore, diff_str, getplural(bluescore))

		if (gametyperules & GTR_TEAMFLAGS) then
			local redplayers, blueplayers
			
			for player in players.iterate do
				if (player.gotflag & GF_REDFLAG) then
					redplayers = player
				end
				
				if (player.gotflag & GF_BLUEFLAG) then
					blueplayers = player
				end

				flags = $ | player.gotflag
			end

			// i do not care about long names doe
			if (flags & GF_REDFLAG) then
				str_r = string.format("%s\x80 has the \x85%s\x80!", JoeBase.GetPlayerName(redplayers, false, false), "Red Flag")
			end

			if (flags & GF_BLUEFLAG) then
				str_b = string.format("%s\x80 has the \x84%s\x80!", JoeBase.GetPlayerName(blueplayers, false, false), "Blue Flag")
			end
		end
		
		JoeRankings.DoIcons(v, x, 5, V_SNAPTORIGHT, diff_ico, skincolor_redteam)
		JoeRankings.DoIcons(v, x, 13, V_SNAPTORIGHT, diff_ico, skincolor_blueteam)

		v.drawString(x - 4, 5, str_r, V_SNAPTORIGHT|V_ALLOWLOWERCASE, "thin-right")
		v.drawString(x - 4, 13, str_b, V_SNAPTORIGHT|V_ALLOWLOWERCASE, "thin-right")
	end

	//
	-- Extra thing
	//

	v.drawString(160, 184, "People spectating:", V_ALLOWLOWERCASE|V_YELLOWMAP, "small-center")

	if G_GametypeHasSpectators() then
		J_SpectatorTicker(v)
	end
end