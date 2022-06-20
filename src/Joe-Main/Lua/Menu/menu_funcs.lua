local function JM_HandleAdmin(menu)
	if (consoleplayer == server) or IsPlayerAdmin(consoleplayer) then
		menu[1].content[5].flags = $ &~ MIF_DISABLED
	else
		menu[1].content[5].flags = $ | MIF_DISABLED
	end
end

local function JM_RenderPlayer(v, menu)
	local player = consoleplayer -- yeah...

	//
	-- draw your current character walking!
	//
	local sprite2 = SPR2_STND
	local frame = 0
	
	if P_IsValidSprite2(player.realmo, SPR2_WALK) then // if some skin doesnt have a walk animation, default it to the stand one
		sprite2 = SPR2_WALK
		frame = (leveltime / 4) % skins[player.skin].sprites[sprite2].numframes
	end
		
	local patch = v.getSprite2Patch(player.skin, sprite2, false, frame, 3)
	local scale = skins[player.skin].highresscale
	v.drawScaled(84 * FRACUNIT, 182 * FRACUNIT, scale, patch, V_FLIP, v.getColormap(TC_BLINK, player.skincolor))

	//
	-- total server time
	//

	local function getstring(val, str)
		return (val == 1) and str or (str .. "s")
	end

	local tics = server.jointime
	local str = "nil"

	local hours = G_TicsToHours(tics)
	local minutes = G_TicsToMinutes(tics)
	local seconds = G_TicsToSeconds(tics)

	if (tics) then
		// too long!
		if (hours > 0) then
			str = string.format("%d %s, %d %s, and %d %s.", hours, getstring(hours, "hour"), minutes, getstring(minutes, "minute"), seconds, getstring(seconds, "second"))
					
		// mid
		elseif (minutes > 0) then
			str = string.format("%d %s, and %d %s.", minutes, getstring(minutes, "minute"), seconds, getstring(seconds, "second"))
		
		// the most basic thing
		elseif (seconds > 0) then
			str = string.format("%d %s.", seconds, getstring(seconds, "second"))
		end
	end

	v.drawString(212, 144, "Server lifetime:", V_ALLOWLOWERCASE|V_YELLOWMAP, "thin-center")
	v.drawString(212, 152, str, V_ALLOWLOWERCASE, "thin-center")

	LM_DrawStandardMenu(v, menu)
end

local joe_menu = {
	[1] = {
		attributes = {
			pos = {30, 30},
			header = {text = "Joe's Server Menu", color = V_GREENMAP},
			start = 2,
			previous = {page = -1, item = 2},
			style = MMT_CUSTOM
		},

		functions = {handler = nil, ticker = JM_HandleAdmin, drawer = JM_RenderPlayer},
		
		content = {
			{id = MIT_HEADER, flags = 0, string = "Header", color = 0, func = nil, cvar = nil, pos_y = 0},
			
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Go to another page...", color = 0, func = page2, cvar = nil, pos_y = 12},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "My Color", color = 0, func = nil, cvar = CV_FindVar("color"), pos_y = 32},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Live System", color = 0, func = nil, cvar = CV_FindVar("cooplives"), pos_y = 42},

			{id = MIT_STRING, flags = 0, string = "Admin only item!", color = V_SKYMAP, func = nil, cvar = nil, pos_y = 62}
		}
	}
}

-- open the menu via a command
COM_AddCommand("joe_menu", function(player)

	CONS_Printf(player, "LOL! This shit is unfinished, don't ever do anything here again.")

	/*

	if (gamestate ~= GS_LEVEL) then
		CONS_Printf(player, "This can only be used in a \x82level\x80!")
		return
	end

	LM_OpenMenu(joe_menu, 1)*/
end, COM_LOCAL)