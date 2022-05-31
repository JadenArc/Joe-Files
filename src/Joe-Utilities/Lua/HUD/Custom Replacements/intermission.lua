//
// Custom Intermission
// By Jaden
//
// TODO: This can be more organized...
//

local inter_tics = 0
local inter_totalscore = 0

local inter_skipped = false

local inter_bonus = {}

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

local function I_GetTimeBonus(time)
	local secs = time / TICRATE
	local bonus = 0

	if (stagefailed) then
		// Time Bonus would be very easy to cheese by failing immediately.
		bonus = 0
	else
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
		end
	end

	return bonus
end

local function I_GetGuardBonus(times)
	local bonus = 0

	if (stagefailed) then
		// "No-hit" runs would be very easy to cheese by failing immediately.
		bonus = 0
	else
		// Time shit! Wait, WAI-
		if     (times == 0) bonus = 10000
		elseif (times == 1) bonus = 5000
		elseif (times == 2) bonus = 1000
		elseif (times == 3) bonus = 500
		elseif (times == 4) bonus = 100
		end
	end

	return bonus
end

-- recreation of G_IsSpecialStage so i can be happy without "This can only be used on a level!" error.
local function I_IsSpecialStage(map)
	if (mapheaderinfo[map].typeoflevel & TOL_NIGHTS) then
		return true
	end

	if (map >= sstage_start and map <= sstage_end) then
		return true
	end

	if (map >= smpstage_start and map <= smpstage_end) then
		return true
	end

	return false
end

-- shortcut.
local function I_DoBonus(r, i, s)
	return table.insert(inter_bonus, {reward = r, info = i, string = s})
end

-- draw a solid blue textbox.
local function V_DrawBox(v, x, y, width, boxlines)
	local col = 159

	if (mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE) then
		col = 45
	end

	v.drawFill(x + 6, y + 6, (width*8) + 7, (boxlines*8) + 7, 31)
	v.drawFill(x + 5, y + 5, (width*8) + 6, (boxlines*8) + 6, col)
end

-- translated from f_finale.c (see F_GameEvaluationDrawer)
local function V_DrawEmeralds(v)
	local x, y;
	local fa;

	local direction = (inter_tics % 360) << FRACBITS

	for i = 0, 6 do
		local patches = v.cachePatch("CHAOS" .. (i + 1))
		local flags = V_80TRANS
		
		fa = FixedAngle(direction)
		
		x = (320 << 15) + (48 * cos(fa))
		y = (216 << 15) + (48 * sin(fa))

		direction = $ + ((360 << FRACBITS) / 7)

		if (emeralds & (EMERALD1 << i)) then flags = 0 end
		if (All7Emeralds(emeralds) and not (inter_tics & 1)) then flags = V_70TRANS end
		
		v.drawScaled(x - (13*FRACUNIT), y - (6*FRACUNIT), FRACUNIT, patches, flags)
	end
end

//
// Thinkers
//

local I_ResetVars = function()
	inter_tics = 0
	inter_totalscore = 0

	inter_skipped = false

	inter_bonus = {}
end

local I_Ticker = function()
	inter_tics = $ + 1

	// only draw this on friendly gametypes, i dont want to redo the results screen in most gametypes
	if not (gametyperules & GTR_FRIENDLY) or (gametyperules & GTR_RACE) then return end

	local map_bonustype = mapheaderinfo[gamemap].bonustype
	local inter_delay = I_IsSpecialStage(gamemap) and (TICRATE*2) or (TICRATE) 

	-- Cache sum stuff
	if (inter_tics == 1) then
		local ring_count = (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) and consoleplayer.totalmarescore or max(0, consoleplayer.rings * 100)

		-- NiGHTS or Special Stages. (logic, since it isnt actually drawn.)
		if (map_bonustype == -1) then
			I_DoBonus(0, ring_count,  "")
			I_DoBonus(0, 		  0,  "")
			I_DoBonus(1, 		nil, nil)

			I_DoBonus(2, 		  0,  "")
			
		-- Time bonus
		elseif (map_bonustype == 0) then
			I_DoBonus(0, I_GetTimeBonus(consoleplayer.realtime),    "Total Time:")
			I_DoBonus(0, 							 ring_count,    "Ring Bonus:")
			I_DoBonus(1, 									nil, "Perfect Bonus:")

			I_DoBonus(2, 									  0, 		 "Total:")

		-- Guard bonus, but you got hit.
		elseif (map_bonustype == 1) then
			I_DoBonus(0, I_GetGuardBonus(consoleplayer.timeshit), "Guard Bonus:")
			I_DoBonus(0, 							  ring_count,  "Ring Bonus:")
			I_DoBonus(1, 									 nil,            nil)
			
			I_DoBonus(2, 									   0, 		"Total:")

		-- Guard bonus, but we are on ERZ3. (why???)
		elseif (map_bonustype == 2) then
			I_DoBonus(0, I_GetGuardBonus(consoleplayer.timeshit), 	"Guard Bonus:")
			I_DoBonus(0, 							  ring_count,  	 "Ring Bonus:")
			I_DoBonus(1,									 nil, "Perfect Bonus:")
			
			I_DoBonus(2, 									   0, 		  "Total:")
		end

	-- Do the rest now
	elseif (inter_tics > inter_delay) then
		for _, inter in ipairs(inter_bonus) do
			if (inter.reward ~= 0) or not inter.info then continue end
				
			inter.info = $ - 222
			inter_totalscore = $ + 222
		
			if (inter.info < 0) or (inter_skipped) or (stagefailed) then
				inter_totalscore = $ + inter.info
				inter.info = 0
			end
		end
			
		for player in players.iterate do
			if (player.cmd.buttons & BT_SPIN) then
				inter_skipped = true
			end
		end
	end
end

addHook("MapChange", I_ResetVars)
addHook("IntermissionThinker", I_Ticker)

//
// HUD Drawing
//

-- Messages!
local IH_DrawMessages = function(v)
	local cv_intertime = CV_FindVar("inttime").value

	local y = 191
	local flags = V_YELLOWMAP|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE

	-- if we detect MapVote, draw a string and forget the things below.
	if rawget(_G, "MapVote") then
		v.drawString(160, y + 4, "\x82Join our Discord: \x80" .. cv_discordlink.string, V_ALLOWLOWERCASE|V_SNAPTOBOTTOM, "small-center")
		return
	end

	// we are on a Netgame!
	if (netgame) then
		if (cv_intertime ~= 0) then
			local timeleft = ((cv_intertime * TICRATE) - inter_tics + 35) / TICRATE

			local str = string.format("Speeding off in %d second%s.", timeleft, (timeleft == 1) and "" or "s")

			v.drawString(160, y, str, flags|V_SNAPTOLEFT, "thin-center")
		end
	
	// we are on Singleplayer!
	else
		v.drawString(3, y - 8, "Good job!", flags|V_SNAPTOLEFT, "thin")
		v.drawString(3, y, "Speeding off to the next level...", flags|V_SNAPTOLEFT, "thin")
	end

	if not (netgame) then
		v.drawString(317, y - 8, "Join our discord server!", flags|V_SNAPTORIGHT, "thin-right")
		v.drawString(317, y, cv_discordlink.string, V_ALLOWLOWERCASE|V_SNAPTORIGHT|V_SNAPTOBOTTOM, "thin-right")
	end
end

-- "You got through the act!"
local IH_DrawIntermission = function(v, stagefailed)
	//
	// Zigzags.
	//

	local colormap = v.getColormap(TC_DEFAULT, (mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE) and SKINCOLOR_CRIMSON or consoleplayer.skincolor)

	local zigzag, zztext, zztext_flip, colormap = V_GetZigPatch(v, consoleplayer)

	local zz_offs = inter_tics % zigzag.height
	local zt_offs = inter_tics % zztext.height
	local zf_offs = inter_tics % zztext_flip.height

	-- Zigzags --
	
	v.draw(0, 				 -(zz_offs), zigzag, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.draw(0, (zigzag.height - zz_offs), zigzag, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	
	v.draw(320, 				 (zz_offs), zigzag, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)
	v.draw(320, (-zigzag.height + zz_offs), zigzag, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)

	-- "Sonic Robo Blast 2" --

	v.draw(0, 				   (zt_offs), zztext, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.draw(0, (-zztext.height + zt_offs), zztext, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)

	v.draw(304, 			  		-(zf_offs), zztext_flip, V_SNAPTORIGHT|V_SNAPTOTOP, colormap)
	v.draw(304, (zztext_flip.height - zf_offs), zztext_flip, V_SNAPTORIGHT|V_SNAPTOTOP, colormap)
	
	//
	// Skip all of the following if we are on a voting section of MapVote.
	//

	if (rawget(_G, "MapVoteNet") and (MapVoteNet.state == MV_VOTE or MapVoteNet.state == MV_END)) then
		return
	end

	//
	// Zone Header.
	//
	
	local yoffs = 8

	local player_name = JoeBase.GetPlayerName(consoleplayer, false, false)
	local has_act = (mapheaderinfo[gamemap].actnum)

	local str = string.format("%s\x80 got", (string.len(player_name) > 8) and "\x82You" or player_name)
	local str_act = string.format("%s", has_act and "through" or "through the act.")

	V_CenterLevelTitle(v, yoffs, str)

	-- are we on a special stage?
	if I_IsSpecialStage(gamemap) then
		yoffs = $ + 20

		local str_st = ""

		-- yeah.
		if All7Emeralds(emeralds) then
			str_st = "all the Emeralds!"

		-- self-explanatory.
		elseif (stagefailed) then
			str_st = "nothing."
		
		-- .haey
		else
			str_st = "a Chaos Emerald!"
		end

		V_CenterLevelTitle(v, yoffs, str_st)
		V_DrawEmeralds(v)
	
	-- otherwise, if we are on a normal level...
	else

		yoffs = $ + 18

		V_CenterLevelTitle(v, yoffs, str_act)

		if has_act then
			local act_patch = v.cachePatch(string.format("TTL%.2d", has_act))
			local flags = V_YELLOWMAP

			v.drawString(160, 62, "Act", V_YELLOWMAP|V_ALLOWLOWERCASE, "center")
			V_DrawLevelActNum(v, 160, 74, has_act, true)
		end
	end

	//
	// Total, Rings, Perfect, etc...
	//

	-- only draw total on special stages, so we can see the emeralds
	if I_IsSpecialStage(gamemap) then
		local flags = (stagefailed) and V_TRANSLUCENT or 0

		V_DrawBox(v, 62, 166, 22, 1)

		v.drawString(74, 175, "Total:", flags|V_ALLOWLOWERCASE|V_YELLOWMAP, "thin")
		v.drawString(244, 175, inter_totalscore, flags|V_ALLOWLOWERCASE, "thin-right")

		return
	end

	V_DrawBox(v, 48, 113, 26, 6)

	for i, inter in ipairs(inter_bonus) do
		if (inter.reward == 1) and not (inter.info ~= nil) then continue end
		
		local bonus_type = (inter.reward == 2) and inter_totalscore or inter.info
		
		local y = 126 + (10 * (i - 1))
		local flags = (stagefailed) and V_TRANSLUCENT or 0

		v.drawString(68, y, inter.string, flags|V_ALLOWLOWERCASE|V_YELLOWMAP)

		v.drawString(252, y, bonus_type, flags, "right")
	end
end

-- All of it.
local IH_IntermissionDrawer = function(v, stagefailed)
	if not (gametyperules & GTR_FRIENDLY) or (gametyperules & GTR_RACE) then return end
	
	hud.disable("intermissionmessages")
	hud.disable("intermissiontally")

	v.fadeScreen(0xFF00, 16) -- yeah
	
	IH_DrawIntermission(v, stagefailed)
	IH_DrawMessages(v)
end

addHook("HUD", IH_IntermissionDrawer, "intermission")