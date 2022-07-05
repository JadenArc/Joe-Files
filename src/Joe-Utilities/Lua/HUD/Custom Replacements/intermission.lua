//
-- Custom Intermission
-- By Jaden
--
-- This may be ugly if you have some shitty internet.
//

local inter_tics = 0

local inter_struct = {
	-- total score between time, and rings.
	totalscore = 0,

	-- did you press spin?
	skipped = false,

	-- a
	bonus = {}
}

-- sum constants
local INT_NORMAL, INT_PERFECT, INT_TOTAL = 0, 1, 2

//
// CVars
//

local cv_discordlink = CV_RegisterVar({
	name = "discordlink",
	defaultvalue = "Not set.",
	flags = CV_NETVAR|CV_CALL|CV_NOINIT,
	possiblevalue = nil,
	func = function(var)
		if var.changed then
			print("Alright! The Discord server link has changed to: \x82" .. var.string .. "\x80.")
		end
	end
})

//
// Functions (mostly from source)
//

-- recreation of G_IsSpecialStage so i can be happy without "This can only be used on a level!" error.
local function I_IsSpecialStage(map)
	if (map >= sstage_start and map <= sstage_end) then
		return true
	end

	if (map >= smpstage_start and map <= smpstage_end) then
		return true
	end

	return false
end

-- Insert the following
local function I_DoBonus(r, i, p)
	table.insert(inter_struct.bonus, {reward = r, info = i, patch = p})
end

//
// Intermission logic (source too)
//

local function I_GetTimeBonus(player)
	local secs = player.realtime / TICRATE
	local bonus = 0

	// Calculate time bonus.
	if     (secs <  30) then bonus = 50000  //  0:30
	elseif (secs <  60) then bonus = 10000  //  1:00
	elseif (secs <  90) then bonus = 5000   //  1:30
	elseif (secs < 120) then bonus = 4000   //  2:00
	elseif (secs < 180) then bonus = 3000   //  3:00
	elseif (secs < 240) then bonus = 2000	//  4:00
	elseif (secs < 300) then bonus = 1000	//  5:00
	elseif (secs < 360) then bonus = 500	//  6:00
	elseif (secs < 420) then bonus = 400	//  7:00
	elseif (secs < 480) then bonus = 300	//  8:00
	elseif (secs < 540) then bonus = 200	//  9:00
	elseif (secs < 600) then bonus = 100	// 10:00
	else
		bonus = 0 // You're too slow!
	end

	return bonus
end

local function I_GetGuardBonus(player)
	local bonus = 0
	local times = player.timeshit

	// Time shit! Wait, WAI-
	if     (times == 0) then bonus = 10000
	elseif (times == 1) then bonus = 5000
	elseif (times == 2) then bonus = 1000
	elseif (times == 3) then bonus = 500
	elseif (times == 4) then bonus = 100
	end

	return bonus
end

local function I_GetRingBonus(player)
	local totalrings = 0

	for stplyr in players.iterate do
		totalrings = $ + stplyr.rings
	end

	-- are we on an actual NiGHTS level?
	if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then
		return player.totalmarescore
	
	-- NiGHTS Special Stages, and the MP ones too!
	elseif I_IsSpecialStage(gamemap) then
		return totalrings * 100

	-- Normal level.
	else
		return player.rings * 100
	end

	return 0
end

local function I_GetLinkBonus(player)
	return max(0, (player.maxlink - 1) * 100)
end

local function I_GetLapBonus(player)
	return max(0, player.totalmarebonuslap * 1000)
end

local I_SetBonus = {
	-- None
	[-1] = function(player)
		return
	end,

	-- Time Bonus
	[0] = function(player)
		I_DoBonus(INT_NORMAL, I_GetTimeBonus(player),  "YB_TIME")
		I_DoBonus(INT_NORMAL, I_GetRingBonus(player),  "YB_RING")
		I_DoBonus(INT_PERFECT, 					 nil, "YB_PERFE")

		I_DoBonus(INT_TOTAL, 					   0, "YB_TOTAL")
	end,

	-- Guard Bonus
	[1] = function(player)
		I_DoBonus(INT_NORMAL, I_GetGuardBonus(player), "YB_GUARD")
		I_DoBonus(INT_NORMAL,  I_GetRingBonus(player),  "YB_RING")
		I_DoBonus(INT_PERFECT,					  nil, 		  nil)
			
		I_DoBonus(INT_TOTAL, 						0, "YB_TOTAL")
	end,

	-- ERZ3 (???)
	[2] = function(player)
		I_DoBonus(INT_NORMAL, I_GetGuardBonus(player), "YB_GUARD")
		I_DoBonus(INT_NORMAL,  I_GetRingBonus(player),  "YB_RING")
		I_DoBonus(INT_PERFECT,					  nil, "YB_PERFE")
			
		I_DoBonus(INT_TOTAL, 						0, "YB_TOTAL")
	end,

	//
	// The following just runs the logic, nothing more.
	//

	-- NiGHTS
	[3] = function(player)
		I_DoBonus(INT_NORMAL, I_GetRingBonus(player), nil)
		I_DoBonus(INT_NORMAL,  I_GetLapBonus(player), nil)
		I_DoBonus(INT_PERFECT, 					 nil, nil)

		I_DoBonus(INT_TOTAL, 					   0, nil)
	end,

	-- NiGHTS, link?
	[4] = function(player)
		I_DoBonus(INT_NORMAL, I_GetLinkBonus(player), nil)
		I_DoBonus(INT_NORMAL,  I_GetLapBonus(player), nil)
		I_DoBonus(INT_PERFECT,					 nil, nil)

		I_DoBonus(INT_TOTAL,					   0, nil)
	end
}


-- translated from f_finale.c (see F_GameEvaluationDrawer)
local function V_DrawEmeralds(v)
	local x, y;
	local fa;

	local direction = (inter_tics % 360) << FRACBITS

	for i = 0, 6 do
		local patch = v.cachePatch("CHAOS" .. (i + 1))
		local flags = V_80TRANS
		
		fa = FixedAngle(direction)
		
		x = (307 << 15) + (42 * cos(fa))
		y = (222 << 15) + (28 * sin(fa))

		direction = $ + ((360 << FRACBITS) / 7)

		if (emeralds & (EMERALD1 << i)) then flags = 0 end
		
		v.drawScaled(x, y, FRACUNIT, patch, flags)
	end
end

//
// Thinkers
//

local I_ResetVars = function()
	inter_tics = 0
	
	inter_struct.totalscore = 0
	inter_struct.skipped = false
	inter_struct.bonus = {}
end

local I_Ticker = function()
	inter_tics = $ + 1
	
	local inter_delay = I_IsSpecialStage(gamemap) and (TICRATE*2) or (TICRATE) 

	-- Cache sum stuff
	if (inter_tics == 1) then
		I_SetBonus[mapheaderinfo[gamemap].bonustype](consoleplayer)
	end

	-- sussy pussy
	if (inter_tics < inter_delay) then return end

	-- Do the rest now
	for player in players.iterate do
		if (player.cmd.buttons & BT_SPIN) then
			inter_struct.skipped = true
		end
	end

	for _, inter in ipairs(inter_struct.bonus) do
		if (inter.info == nil) then continue end
				
		inter.info = $ - 222
		inter_struct.totalscore = $ + 222
		
		if (inter.info < 0) or (inter_struct.skipped) then
			inter_struct.totalscore = $ + inter.info
			inter.info = 0
		end
	end
end

addHook("MapLoad", I_ResetVars)
addHook("IntermissionThinker", I_Ticker)

//
// HUD Drawing
//

-- Messages!
local IH_DrawMessages = function(v)
	local cv_intertime = CV_FindVar("inttime").value

	local y = 191
	local flags = V_SNAPTOBOTTOM|V_ALLOWLOWERCASE

	-- if we detect MapVote, draw a string and forget the things below.
	if rawget(_G, "MapVote") then
		v.drawString(160, y + 4, "\x82Join our Discord: \x80" .. cv_discordlink.string, flags, "small-center")
		return
	end

	// we are on a Netgame!
	if (netgame) then
		if (cv_intertime ~= 0) then
			local timeleft = ((cv_intertime * TICRATE) - inter_tics + 35) / TICRATE

			local str = string.format("Speeding off in %d second%s.", timeleft, (timeleft == 1) and "" or "s")

			v.drawString(3, y, str, flags|V_YELLOWMAP|V_SNAPTOLEFT, "thin")
		end
		
		-- discord?
		v.drawString(317, y - 8, "Join our discord server!", flags|V_SNAPTORIGHT|V_YELLOWMAP, "thin-right")
		v.drawString(317, y, cv_discordlink.string, V_SNAPTORIGHT|flags, "thin-right")
	
	// we are on Singleplayer!
	else
		v.drawString(160, y, "Speeding off to the next level...", flags|V_YELLOWMAP, "thin-center")
	end
end

-- "You got through the act!"
-- Note: too much easing!!!!!!!!!
local IH_DrawIntermission = function(v, stagefailed)
	//
	// Animations
	//

	local inter_anim = JoeBase.GetEasingTics(inter_tics)
	local inter_trueanims = {
		-- zigzags
		[0] = ease.outexpo(inter_anim, 200, 0),

		-- title
		[1] = ease.outback(inter_anim - 4, 640, 0),

		-- scores
		[2] = ease.inoutquart(inter_anim - 8, 640, 0)
	}

	//
	// Zigzags.
	//

	local zigzag, zigzag_flip = v.cachePatch("JH_ZIGZAG"), v.cachePatch("JH_ZIGZAG_F")
	local zztext, zztext_flip = v.cachePatch("JH_ZZTEXT"), v.cachePatch("JH_ZZTEXT_F")

	local colormap = v.getColormap(TC_DEFAULT, (consoleplayer.skincolor) or R_GetColorByName(CV_FindVar("color").string))

	local zz_offs = inter_tics % zigzag.width
	local zzf_offs = inter_tics % zigzag_flip.width
	
	local zt_offs = inter_tics % zztext.width
	local ztf_offs = inter_tics % zztext_flip.width

	-- Top --
	
	v.draw(				 	  -(zzf_offs), -inter_trueanims[0], zigzag_flip, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.draw((zigzag_flip.width - zzf_offs), -inter_trueanims[0], zigzag_flip, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)

	v.draw(				  	    (ztf_offs), -inter_trueanims[0], zztext_flip, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.draw((-zztext_flip.width + ztf_offs), -inter_trueanims[0], zztext_flip, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	
	-- Bottom --

	v.draw(				   (zz_offs), 158 + inter_trueanims[0], zigzag, V_SNAPTOLEFT|V_SNAPTOBOTTOM, colormap)
	v.draw((-zigzag.width + zz_offs), 158 + inter_trueanims[0], zigzag, V_SNAPTOLEFT|V_SNAPTOBOTTOM, colormap)

	v.draw(				 -(zt_offs), 184 + inter_trueanims[0], zztext, V_SNAPTOLEFT|V_SNAPTOBOTTOM, colormap)
	v.draw((zztext.width - zt_offs), 184 + inter_trueanims[0], zztext, V_SNAPTOLEFT|V_SNAPTOBOTTOM, colormap)
	
	//
	// Skip all of the following if we are on a voting section of MapVote.
	//

	if (rawget(_G, "MapVoteNet") and (MapVoteNet.state == MV_VOTE or MapVoteNet.state == MV_END)) then
		return
	end

	//
	// Zone Header.
	//
	
	local yoffs = 40

	local player_name = JoeBase.GetPlayerName(consoleplayer, false, false)
	local has_act = (mapheaderinfo[gamemap].actnum)
	
	local zone_strings = {
		-- "player" got
		[0] = string.format("%s\x80 got", (player_name:len() > 11) and "\x82You" or player_name),

		-- through the ...
		[1] = string.format("%s", has_act and "through" or ((mapheaderinfo[gamemap].levelflags & LF_NOZONE) and "through the stage." or "through the act.")),

		-- Special Stage
		[2] = string.format("%s", ((stagefailed) and "nothing.") or (All7Emeralds(emeralds) and "them All!") or "a Chaos Emerald!")
	}
	
	V_AlignLevelTitle(v, 160 + inter_trueanims[1], yoffs, zone_strings[0], "center")

	-- are we on a special stage?
	if I_IsSpecialStage(gamemap) then
		yoffs = $ + 19

		V_AlignLevelTitle(v, 160 - inter_trueanims[1], yoffs, zone_strings[2], "center")
		V_DrawEmeralds(v)
	
	-- otherwise, if we are on a normal level...
	else
		yoffs = $ + 18

		V_AlignLevelTitle(v, 160 - inter_trueanims[1], yoffs, zone_strings[1], "center")

		-- act number (im too lazy)
		if has_act then
			v.drawString(160 + inter_trueanims[1], yoffs + 21, "Act " .. has_act, V_YELLOWMAP|V_ALLOWLOWERCASE, "center")
		end
	end

	//
	// Total, Rings, Perfect, etc...
	//

	local flags = (stagefailed) and V_TRANSLUCENT or 0

	-- only draw total on special stages, so we can see the emeralds
	if I_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then

		v.draw(132 - inter_trueanims[2], 166, v.cachePatch("YB_TOTAL"), flags)
		v.drawNum(252 + inter_trueanims[2], 167, inter_struct.totalscore, flags)

		return
	end

	for i, inter in ipairs(inter_struct.bonus) do
		if (inter.info == nil) then continue end
		
		local bonus_type = (inter.reward == INT_TOTAL) and inter_struct.totalscore or inter.info
		local y = 93 + (16 * (i - 1))

		v.draw(132 - inter_trueanims[2], y, v.cachePatch(inter.patch), flags)
		v.drawNum(272 + inter_trueanims[2], y + 1, bonus_type, flags)
	end
end

-- All of it.
local IH_IntermissionDrawer = function(v, stagefailed)
	hud.disable("intermissionmessages")

	if (gametyperules & GTR_FRIENDLY) and not (gametyperules & GTR_RACE) then
		hud.disable("intermissiontally")
	else
		IH_DrawMessages(v)
		hud.enable("intermissiontally")
		return
	end

	v.fadeScreen(0xFF00, 16) -- yeah
	
	IH_DrawIntermission(v, stagefailed)
	IH_DrawMessages(v)
end

addHook("HUD", IH_IntermissionDrawer, "intermission")