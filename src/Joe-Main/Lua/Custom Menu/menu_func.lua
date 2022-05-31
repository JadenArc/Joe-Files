/* 
The full ass menu.
Comment added by Jaden
*/

local function LM_MenuMainThinker(player)
	if (server ~= player) and not IsPlayerAdmin(player) then
		player.menu.content[1].content[2].flags = $ | MIF_DISABLED
		if (player.menu.selected == 2) then player.menu.selected = 3 end
	else
		player.menu.content[1].content[2].flags = $ & ~(MIF_DISABLED)
	end
	-- apparently you can select the header when you open the menu or go back from a category, so cool!!!!!1111
	if (player.menu.selected == 1) then player.menu.selected = 2 end
end

local function LM_MenuClose(player)
	player.menu.show = false
	player.menu.content = nil
end

local function LM_MenuGotoMain(player)
	player.menu.selected = 1
	player.menu.page = 1
end

local function LM_MenuGotoAdmin(player)
	player.menu.selected = 2
	player.menu.page = 2
end

local function LM_MenuGotoPlayer(player)
	player.menu.selected = 2
	player.menu.page = 3
end

local function LM_MenuPlayerTogglePrivacy(player)
	COM_BufInsertText(player, "togglepm")
end

local function LM_MenuAdminToggleChat(player)
	COM_BufInsertText(server, "togglechat")
end

local function LM_MenuAdminThinker(player)
	if (server ~= player) and not IsPlayerAdmin(player) then
		player.menu.selected = 2
		player.menu.page = 1
	end
	
	/* Server Section */

	-- afk options
	/*if not ltools.cv_server_afkenabled.value then
		player.menu.content[2].content[12].flags = $ | MIF_DISABLED
		if (player.menu.selected == 12) then player.menu.selected = 11 end
	else
		player.menu.content[2].content[12].flags = $ & ~(MIF_DISABLED)
		
		if not ltools.cv_server_afkkickenabled.value then
			player.menu.content[2].content[15].flags = $ | MIF_DISABLED
			if (player.menu.selected == 15) then player.menu.selected = 14 end
		else
			player.menu.content[2].content[15].flags = $ & ~(MIF_DISABLED)
		end
	end*/
	
	-- momentum
	if not joethings.momentum.value then
		player.menu.content[2].content[20].flags = $ | MIF_DISABLED
		if (player.menu.selected == 20) then player.menu.selected = 19 end
	else
		player.menu.content[2].content[20].flags = $ & ~(MIF_DISABLED)
	end

	if not joethings.momentum.value then -- turn this off
		CV_StealthSet(joethings.momvfx, "Off")
	end
end

local Joes_Menu = {
	[1] = {
		previous = 0,
		previous_item = 0,
		pos_x = 30,
		pos_y = 30,
		ticker = LM_MenuMainThinker,
		music = "JOEMEN",
		style = MMT_NORMAL,
		header = "Joe's Server Menu",
		color = 0,
		content = {
			{id = MIT_HEADER, flags = 0, string = "Options", color = 0, func = nil, cvar = nil, pos_y = 100},
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Server options...", color = 0, func = LM_MenuGotoAdmin, cvar = nil, pos_y = 112},
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Player options...", color = 0, func = LM_MenuGotoPlayer, cvar = nil, pos_y = 122},
			
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Close Menu...", color = 0, func = LM_MenuClose, cvar = nil, pos_y = 142}
		}
	},
	
	[2] = {
		previous = 1,
		previous_item = 1,
		pos_x = 30,
		pos_y = 30,
		ticker = LM_MenuAdminThinker,
		music = "JOEMEN",
		style = MMT_SCROLL,
		header = "Server options",
		color = V_PERIDOTMAP,
		content = {			
/*			{id = MIT_HEADER, flags = 0, string = "Custom Chat - General", color = 0, func = nil, cvar = nil, pos_y = 0},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Custom Chat", color = 0, func = nil, cvar = CV_FindVar("server_customchat_enabled"), pos_y = 12},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Macros enabled", color = 0, func = nil, cvar = CV_FindVar("server_customchat_macros"), pos_y = 22},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Sounds enabled", color = 0, func = nil, cvar = CV_FindVar("server_customchat_sounds"), pos_y = 32},
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Mute chat...", color = 0, func = LM_MenuAdminToggleChat, cvar = nil, pos_y = 42},
			
			{id = MIT_HEADER, flags = 0, string = "Custom Chat - Anti spam", color = 0, func = nil, cvar = nil, pos_y = 60},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Anti Spam", color = 0, func = nil, cvar = CV_FindVar("server_customchat_antispam_enabled"), pos_y = 72},
			{id = MIT_STRING, flags = MIF_CVAR_NUMBER, string = "Anti Spam - Rate", color = 0, func = nil, cvar = CV_FindVar("server_customchat_antispam_rate"), pos_y = 82},
			{id = MIT_STRING, flags = MIF_CVAR_NUMBER, string = "Anti Spam - Mute time (mins)", color = 0, func = nil, cvar = CV_FindVar("server_customchat_antispam_mutetime"), pos_y = 92},
			
			{id = MIT_HEADER, flags = 0, string = "AFK System - General", color = 0, func = nil, cvar = nil, pos_y = 110},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "AFK", color = 0, func = nil, cvar = CV_FindVar("server_afk_enabled"), pos_y = 122},
			{id = MIT_STRING, flags = MIF_CVAR_NUMBER, string = "AFK - Auto time (mins)", color = 0, func = nil, cvar = CV_FindVar("server_afk_time"), pos_y = 132},
			
			{id = MIT_HEADER, flags = 0, string = "AFK System - Kick", color = 0, func = nil, cvar = nil, pos_y = 150},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "AFK - Kick enabled", color = 0, func = nil, cvar = CV_FindVar("server_afk_kick_enabled"), pos_y = 162},
			{id = MIT_STRING, flags = MIF_CVAR_NUMBER, string = "AFK - Time kick (mins)", color = 0, func = nil, cvar = CV_FindVar("server_afk_kick_time"), pos_y = 172},
			
			{id = MIT_HEADER, flags = 0, string = "General Gameplay", color = 0, func = nil, cvar = nil, pos_y = 190},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Player collisions", color = 0, func = nil, cvar = CV_FindVar("server_gameplay_playersoolision"), pos_y = 202},*/
				
			{id = MIT_HEADER, flags = 0, string = "Momentum - General", color = 0, func = nil, cvar = nil, pos_y = 220},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Momentum", color = 0, func = nil, cvar = CV_FindVar("joe_momentum"), pos_y = 232},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Momentum - Vfx", color = 0, func = nil, cvar = CV_FindVar("joe_momentum-vfx"), pos_y = 242}

			-- {id = MIT_STRING, flags = MIF_FUNCTION, string = "Go Back...", color = 0, func = LM_MenuGotoMain, cvar = nil, pos_y = 332}
		}
	}
}

local function L_OpenMenu(player)
	if not (gamestate == GS_LEVEL) then
		CONS_Printf(player, "This can be only used in a level.")
		return
	end

	CONS_Printf(player, "Menu is on hold since jaden is working hard on it (not really)")

	/*if player.menu.show then
		player.menu.show = false
		player.menu.content = nil
	else
		player.menu.content = Joes_Menu
		player.menu.page = 1
		player.menu.selected = 1
		player.menu.show = true
	end*/
end
COM_AddCommand("joe_menu", L_OpenMenu)

-- menu things
addHook("HUD", function(v, player)
	local x, y = 30, 63

	local function MenuText(str)
		v.drawString(x, y, str, V_ALLOWLOWERCASE, "thin")
		y = $ + 8
	end

	if player.menu and (player.menu.show and player.menu.page == 1) then
		MenuText("\x82" .. "How to use the menu:")		

		MenuText("\x85" .. "Move up/down:" .. "\x80 Select options.")
		MenuText("\x87" .. "Move left/right:" .. "\x80 Change Values.")
		MenuText("\x83" .. "Jump:" .. "\x80 Go to another section.")
		MenuText("\x8B" .. "Spin:" .. "\x80 Go back/Exit menu.")

		-- draw your character walking!
		local sprite2, frame_count, frame
		if P_IsValidSprite2(player.realmo, SPR2_WALK) then // if some skin doesnt have a walk animation, default it to the stand one
			sprite2 = SPR2_WALK
			frame_count = skins[player.realmo.skin].sprites[sprite2].numframes
			frame = (leveltime/4) % frame_count
		else
			sprite2 = SPR2_STND
			frame = 0
		end
		
		local patch = v.getSprite2Patch(player.realmo.skin, sprite2, false, frame, 2)
		local colormap = v.getColormap(player.realmo.skin, player.skincolor)
		v.drawScaled((x + 203)*FRACUNIT, (y + 5)*FRACUNIT, skins[player.realmo.skin].highresscale, patch, V_FLIP, colormap)
	end
end, "game")