local function restartMap()
	G_SetCustomExitVars(gamemap, 3)
	G_ExitLevel()
end

local function doTheThing()
	COM_BufInsertText(consoleplayer, "suicide")
	CONS_Printf(consoleplayer, "Get trolled!")

	LM_CloseMenu()
end

local function page2()
	LM_GoToPage(2)
end

local function menuRender(v, menu)
	local player = consoleplayer -- yeah...

	-- draw your character walking!
	local sprite2 = SPR2_STND
	local frame = 0
	
	if P_IsValidSprite2(player.realmo, SPR2_WALK) then // if some skin doesnt have a walk animation, default it to the stand one
		sprite2 = SPR2_WALK
		frame = (leveltime / 4) % skins[player.skin].sprites[sprite2].numframes
	end
		
	local patch = v.getSprite2Patch(player.skin, sprite2, false, frame, 3)
	local scale = skins[player.skin].highresscale
	v.drawScaled(160 * FRACUNIT, 182 * FRACUNIT, scale, patch, V_FLIP, v.getColormap(TC_BLINK, player.skincolor))

	-- v.drawString(4, 182, string.format("%02d:%02d", G_TicsToMinutes(player.jointime, true), G_TicsToSeconds(player.jointime)), 0, "thin")

	LM_DrawStandardMenu(v, menu)
end

local my_menu = {
	[1] = {
		attributes = {
			pos = {30, 30},
			header = {text = "The Menu Example", color = V_GREENMAP},
			start = 2,
			previous = {page = -1, item = 2},
			style = MMT_CUSTOM
		},

		functions = {handler = nil, ticker = nil, drawer = menuRender},
		
		content = {
			{id = MIT_HEADER, flags = 0, string = "Header", color = 0, func = nil, cvar = nil, pos_y = 0},
			
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Go to another page...", color = 0, func = page2, cvar = nil, pos_y = 12},
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Restart the current map...", color = 0, func = restartMap, cvar = nil, pos_y = 22},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "My Color", color = 0, func = nil, cvar = CV_FindVar("color"), pos_y = 42},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Live System", color = 0, func = nil, cvar = CV_FindVar("cooplives"), pos_y = 52},

			{id = MIT_STRING, flags = MIF_DISABLED, string = "Disabled item!", color = V_REDMAP, func = nil, cvar = nil, pos_y = 72}
		}
	},

	[2] = {
		attributes = {
			pos = {30, 30},
			header = {text = "The Menu Example 2", color = V_PURPLEMAP},
			start = 2,
			previous = {page = 1, item = 1},
			style = MMT_NORMAL
		},

		functions = {handler = nil, ticker = nil, drawer = nil},
		
		content = {
			{id = MIT_HEADER, flags = 0, string = "Header - The Second", color = 0, func = nil, cvar = nil, pos_y = 0},
			
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Text that does something!", color = V_SKYMAP, func = doTheThing, cvar = nil, pos_y = 12}
		}
	}
}

-- open the menu via a command
COM_AddCommand("mymenu", function(player)
	LM_OpenMenu(my_menu, 1)
end, COM_LOCAL)