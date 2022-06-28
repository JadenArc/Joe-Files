//
// Menu Stuff
//

local JM_GotoServer = do LM_GoToPage(2) end
local JM_GotoPlayer = do LM_GoToPage(3) end

local JM_ToggleAFK = do	COM_BufInsertText(consoleplayer, "afk") end

local function JM_HandleMain(menu)
	if (consoleplayer == server) or IsPlayerAdmin(consoleplayer) then
		menu[1].content[2].flags = $ &~ MIF_DISABLED
	else
		menu[1].content[2].flags = $ | MIF_DISABLED
		if (menu_framework.cursor == 2) then menu_framework.cursor = 3 end
	end
end

local function JM_HandleServer(menu)
end

local function JM_HandlePlayer(menu)
	if CV_FindVar("nametags").value then
		menu[3].content[3].flags = $ &~ MIF_DISABLED
	else
		menu[3].content[3].flags = $ | MIF_DISABLED
	end

	if (consoleplayer.afk) then
		menu[3].content[5].string = "Turn AFK Off..."
	else
		menu[3].content[5].string = "Turn AFK On..."
	end
end

//
// HUD Stuff
//

local function JM_RenderPlayer(v, menu)
	local player = consoleplayer -- yeah...

	local drawText = function(x, y, str)
		v.drawString(x, y, str, V_ALLOWLOWERCASE, "thin-center")
	end

	local getstring = function(val, str)
		return (val == 1) and str or (str .. "s")
	end

	//
	-- how do i control this thing?
	//

	drawText(160, 39, "\x82" .. "How to properly use the menu:")

	drawText(84, 48, "\x85" .. "Up/Down Arrow:\x80 Select options.")
	drawText(84, 56, "\x85" .. "Left/Right Arrow:\x80 Change Values.")

	drawText(244, 48, "\x84" .. "Enter:\x80 Go to another section.")
	drawText(244, 56, "\x84" .. "ESC:\x80 Go Back/Exit menu.")

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

	v.drawScaled(84 * FRACUNIT, 138 * FRACUNIT, scale, patch, V_FLIP, v.getColormap(TC_BLINK, player.skincolor))

	//
	-- total server time
	//

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

	v.drawString(216, 108, "Server lifetime:", V_ALLOWLOWERCASE|V_YELLOWMAP, "thin-center")
	v.drawString(216, 116, str, V_ALLOWLOWERCASE, "thin-center")

	LM_DrawStandardMenu(v, menu)
end

//
// The actual menu definitions
//

local joe_menu = {
	// Main Menu
	[1] = {
		attributes = {
			pos = {30, 30},
			header = {text = "Joe's Server Menu", color = V_GREENMAP},
			start = 2,
			previous = {page = -1, item = 2},
			music = "JOEMEN",
			style = MMT_CUSTOM
		},

		functions = {handler = nil, ticker = JM_HandleMain, drawer = JM_RenderPlayer},
		
		content = {
			{id = MIT_HEADER, flags = 0, string = "Main Options", color = 0, func = nil, cvar = nil, pos_y = 130},
			
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Server Options...", color = 0, func = JM_GotoServer, cvar = nil, pos_y = 142},
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Player Options...", color = 0, func = JM_GotoPlayer, cvar = nil, pos_y = 152}
		}
	},

	// Server Options
	[2] = {
		attributes = {
			pos = {30, 30},
			header = {text = "Server Options", color = V_BLUEMAP},
			start = 2,
			previous = {page = 1, item = 2},
			music = "JOEMEN",
			style = MMT_SCROLL
		},

		functions = {handler = nil, ticker = JM_HandleServer, drawer = nil},

		content = {
			{id = MIT_HEADER, flags = 0, string = "AFK Options", color = 0, func = nil, cvar = nil, pos_y = 0},

			{id = MIT_STRING, flags = MIF_CVAR_NUMBER, string = "AFK Delay", color = 0, func = nil, cvar = CV_FindVar("afk_delay"), pos_y = 12},
			{id = MIT_STRING, flags = MIF_CVAR_NUMBER, string = "AFK Kick Timer", color = 0, func = nil, cvar = CV_FindVar("afk_kick"), pos_y = 22}
		}
	},

	// Player Options
	[3] = {
		attributes = {
			pos = {30, 30},
			header = {text = "Player Options", color = V_AZUREMAP},
			start = 2,
			previous = {page = 1, item = 2},
			music = "JOEMEN",
			style = MMT_SCROLL
		},

		functions = {handler = nil, ticker = JM_HandlePlayer, drawer = nil},

		content = {
			{id = MIT_HEADER, flags = 0, string = "HUD Options", color = 0, func = nil, cvar = nil, pos_y = 0},

			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Nametags", color = 0, func = nil, cvar = CV_FindVar("nametags"), pos_y = 12},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Nametags - Show own", color = 0, func = nil, cvar = CV_FindVar("nametags_showown"), pos_y = 22},

			{id = MIT_HEADER, flags = 0, string = "Gameplay Options", color = 0, func = nil, cvar = nil, pos_y = 40},

			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Turn AFK On...", color = 0, func = JM_ToggleAFK, cvar = nil, pos_y = 52}
		}
	}
}

-- open the menu via a command
local CMD_JoeMenu = function(player)
	if (gamestate ~= GS_LEVEL) then
		CONS_Printf(player, "This can only be used in a \x82level\x80.")
		return
	end

	LM_OpenMenu(joe_menu, 1)
end
COM_AddCommand("joe_menu", CMD_JoeMenu, COM_LOCAL)