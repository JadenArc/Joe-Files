/*
	Custom Menu
	Made by Lugent, modified by Jaden
*/

for stupid = 2, 3 do
	freeslot("sfx_menu"..stupid) -- check a merge request that never got merged for these sounds
end

sfxinfo[sfx_menu2].caption = "Changed/Selected a option"
sfxinfo[sfx_menu3].caption = "Went back"

rawset(_G, "createFlags", function(tname, t)
    for i = 1,#t do
        rawset(_G, t[i], 2 ^ (i - 1))
        table.insert(tname, {string = t[i], value = 2 ^ (i - 1)} )
    end
end)

// Menu types
rawset(_G, "MMT_NORMAL", 0)
rawset(_G, "MMT_SCROLL", 1)
rawset(_G, "MMT_CUSTOM", 2)

// Menu item types
rawset(_G, "MIT_STRING", 0)
rawset(_G, "MIT_HEADER", 1)

-- Menu item flags
rawset(_G, "MENUITEMFLAGS", {})
createFlags(MENUITEMFLAGS, {
	"MIF_DISABLED",
	"MIF_FUNCTION",
	"MIF_CVAR_STRING",
	"MIF_CVAR_NUMBER",
	"MIF_CVAR_SLIDER" -- Sadly, Lua can't read CVar's Possible Values. So this is useless
})

-- made by your friendly compiler, Jaden!
local J_DoCheckerScroll = function(v, patch1, patch2, speed)
	local firstchecker = v.cachePatch(patch1)
	local secondchecker = v.cachePatch(patch2)

	v.scroller = $ or 0

	if v.scroller > speed then v.scroller = $ - 1 end
	if v.scroller <= speed then v.scroller = 0 end

	v.draw(0, (v.scroller / 2), firstchecker, V_SNAPTOTOP|V_SNAPTOLEFT)
	v.draw(280, (-v.scroller / 2 - 40), secondchecker, V_SNAPTOTOP|V_SNAPTORIGHT)
end

-- this too!
local function J_DoHeaderTitle(v, menu)
	local color_flag = (menu.color and menu.color or V_YELLOWMAP)
	local doCenter = v.levelTitleWidth(menu.header) / 2

	v.drawLevelTitle(160 - doCenter, 5, menu.header, color_flag)
end

local function LM_ViewpointHandler(player, targetplayer, forced)
	if player.menu and player.menu.show then
		return false
	end
	return
end
addHook("ViewpointSwitch", LM_ViewpointHandler)

local previousmusic = ""
local previousmusicmenu = ""
local previoustime = 0
local previoustimemenu = 0
local function LM_PreThinker()
	for player in players.iterate do
		if player.menu then
			if player.menu.show then
				player.menu.prevpage = player.menu.page
				if (player.menu.content[player.menu.page].music ~= nil) then
					if (S_MusicName() ~= player.menu.content[player.menu.page].music) then
						previousmusic = S_MusicName()
						previoustime = S_GetMusicPosition()
						
						if (previousmusicmenu ~= player.menu.content[player.menu.page].music) then previoustimemenu = 0 end
						S_ChangeMusic(player.menu.content[player.menu.page].music, true, player, 0, previoustimemenu)
					end
				else
					if (previousmusic == "") then
						previousmusic = S_MusicName()
					end
					
					if (S_MusicName() ~= previousmusic) then
						previousmusicmenu = S_MusicName()
						previoustimemenu = S_GetMusicPosition()
						
						S_ChangeMusic(previousmusic, true, player, mapmusflags, previoustime)
					end
				end
			
				if player.menu.content[player.menu.page].ticker then
					player.menu.content[player.menu.page].ticker(player)
				end
			
				player.menu.delay = max($ - 1, 0)

				local go_up = (player.cmd.forwardmove > 0)
				local go_down = (player.cmd.forwardmove < 0)
				local go_left = (player.cmd.sidemove > 0)
				local go_right = (player.cmd.sidemove < 0)

				local pressing_spin = (player.cmd.buttons & BT_SPIN)
				local pressing_jump = (player.cmd.buttons & BT_JUMP)
				
				if not player.menu.delay then
					if go_up then
						local prev_option = player.menu.selected
						repeat
							player.menu.selected = $ - 1
							if not player.menu.selected then
								player.menu.selected = #player.menu.content[player.menu.page].content
							end
						until ((player.menu.content[player.menu.page].content[player.menu.selected].id ~= MIT_HEADER) and not (player.menu.content[player.menu.page].content[player.menu.selected].flags & MIF_DISABLED))
						player.menu.delay = 5
						S_StartSound(nil, sfx_menu1, player)

					elseif go_down then
						local prev_option = player.menu.selected
						repeat
							player.menu.selected = $ + 1
							if (player.menu.selected > #player.menu.content[player.menu.page].content) then
								player.menu.selected = 1
							end
						until ((player.menu.content[player.menu.page].content[player.menu.selected].id ~= MIT_HEADER) and not (player.menu.content[player.menu.page].content[player.menu.selected].flags & MIF_DISABLED))
						player.menu.delay = 5
						S_StartSound(nil, sfx_menu1, player)

					elseif go_right then
						if (player.menu.content[player.menu.page].content[player.menu.selected].flags & (MIF_CVAR_STRING|MIF_CVAR_NUMBER)) then
							--CV_AddValue(player.menu.content[player.menu.page].content[player.menu.selected].cvar, 1)
							COM_BufInsertText(player, "add " .. player.menu.content[player.menu.page].content[player.menu.selected].cvar.name .. " 1")
							player.menu.delay = 5
							S_StartSound(nil, sfx_menu2, player)
						end

					elseif go_left then
						if (player.menu.content[player.menu.page].content[player.menu.selected].flags & (MIF_CVAR_STRING|MIF_CVAR_NUMBER)) then
							--CV_AddValue(player.menu.content[player.menu.page].content[player.menu.selected].cvar, -1)
							COM_BufInsertText(player, "add " .. player.menu.content[player.menu.page].content[player.menu.selected].cvar.name .. " -1")
							player.menu.delay = 5
							S_StartSound(nil, sfx_menu2, player)
						end

					elseif pressing_jump then -- Jaden's note: Theres not a contant for the enter key or anything, sad.
						if (player.menu.content[player.menu.page].content[player.menu.selected].flags & MIF_FUNCTION) then
							if player.menu.content[player.menu.page].content[player.menu.selected].func
								player.menu.content[player.menu.page].content[player.menu.selected].func(player)
								player.menu.delay = 5
								S_StartSound(nil, sfx_menu2, player)
							end
						end

					elseif pressing_spin then
						if (player.menu.content[player.menu.page].previous ~= nil) then
							if (player.menu.content[player.menu.page].previous < 1) then
								player.menu.show = false
							else
								player.menu.selected = player.menu.content[player.menu.page].previous_item
								player.menu.page = player.menu.content[player.menu.page].previous
							end
							player.menu.delay = 5
							S_StartSound(nil, sfx_menu3, player)
						end
					end
				end
				player.powers[pw_nocontrol] = 2
			else
				if (player.menu.prevpage ~= 0) then
					player.menu.prevpage = 0
					
					S_ChangeMusic(previousmusic, true, player, mapmusflags, previoustime)
				end
			end
		end
	end
end
addHook("PreThinkFrame", LM_PreThinker)

local function LM_PlayerSpawn(player)
	player.menu = {}
	player.menu.content = nil
	player.menu.selected = 0
	player.menu.page = 0
	player.menu.prevpage = 0 -- just for checking music
	player.menu.delay = 0
	player.menu.show = false
end
addHook("PlayerSpawn", LM_PlayerSpawn)

local function LM_DrawStandardMenu(v, player, menu)
	if menu.header then
		J_DoHeaderTitle(v, menu)
	end

	local cursor_y = 0
	for item_index, item in ipairs(menu.content) do
		if (item_index == player.menu.selected) then
			cursor_y = item.pos_y
		end
		
		if (item.id == MIT_STRING) then
			local selected_flag = (item_index == player.menu.selected) and V_YELLOWMAP or (item.color and item.color or 0)
			local disabled_flag = (item.flags & MIF_DISABLED) and V_TRANSLUCENT or 0
			local string_flags = disabled_flag|selected_flag
			v.drawString(menu.pos_x, menu.pos_y + item.pos_y, item.string, V_ALLOWLOWERCASE|string_flags, "left")
			
			if (item.flags & MIF_CVAR_STRING) then
				v.drawString(320 - menu.pos_x, (menu.pos_y + item.pos_y), item.cvar.string, V_ALLOWLOWERCASE|string_flags, "right")
				
				if (item_index == player.menu.selected) then
					v.drawString((((320 - menu.pos_x) - 10) - v.stringWidth(item.cvar.string)) - ((leveltime % 9) / 5), (menu.pos_y + item.pos_y), "\x1C", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
					v.drawString(((320 - menu.pos_x) + 2) + ((leveltime % 9) / 5), (menu.pos_y + item.pos_y), "\x1D", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
				end
			elseif (item.flags & MIF_CVAR_NUMBER) then
				v.drawString(320 - menu.pos_x, (menu.pos_y + item.pos_y), item.cvar.value, V_ALLOWLOWERCASE|string_flags, "right")

				if (item_index == player.menu.selected) then
					v.drawString((((320 - menu.pos_x) - 10) - v.stringWidth(item.cvar.value)) - ((leveltime % 9) / 5), (menu.pos_y + item.pos_y), "\x1C", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
					v.drawString(((320 - menu.pos_x) + 2) + ((leveltime % 9) / 5), (menu.pos_y + item.pos_y), "\x1D", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
				end
			elseif (item.flags & MIF_CVAR_SLIDER) then
				v.drawScaled(((320 - menu.pos_x) - 78) * FRACUNIT, (menu.pos_y + item.pos_y) * FRACUNIT, FRACUNIT, v.cachePatch("M_SLIDEL"), string_flags)
				
				for i = 1, 9 do
					v.drawScaled((((320 - menu.pos_x) - 78) + (i * 8)) * FRACUNIT, (menu.pos_y + item.pos_y) * FRACUNIT, FRACUNIT, v.cachePatch("M_SLIDEM"), string_flags)
				end
				v.drawScaled((((320 - menu.pos_x) - 78) + 80) * FRACUNIT, (menu.pos_y + item.pos_y) * FRACUNIT, FRACUNIT, v.cachePatch("M_SLIDER"), string_flags)
				
				/*local slider_range = (item.cvar.flags & CV_FLOAT) and (item.cvar.defaultvalue * FRACUNIT) else item.cvar.defaultvalue
				if (slider_range ~= item.cvar.value) then	
					
				end*/
			end
		elseif (item.id == MIT_HEADER) then
			local color_flag = (item.color and item.color or V_YELLOWMAP)
			v.drawString(19, menu.pos_y + item.pos_y, item.string, V_ALLOWLOWERCASE|color_flag, "left")
			v.drawFill(19, (menu.pos_y + item.pos_y) + 9, 281, 1, 73);
			v.drawFill(300, (menu.pos_y + item.pos_y) + 9, 1, 1, 31);
			v.drawFill(19, (menu.pos_y + item.pos_y) + 10, 281, 1, 31);
		end
	end
	v.drawScaled((menu.pos_x - 24) * FRACUNIT, (menu.pos_y + cursor_y) * FRACUNIT, FRACUNIT, v.cachePatch("M_CURSOR"))
end

local scrollareaheight = 88
local function LM_DrawScrollMenu(v, player, menu)
	if menu.header then
		J_DoHeaderTitle(v, menu)
	end

	local arrowup, arrowdown = false, false
	if (menu.content[#menu.content].pos_y > scrollareaheight) then
		arrowup, arrowdown = false, true
	end
	
	local offset_y = 0
	if (menu.content[player.menu.selected].pos_y >= scrollareaheight) then
		arrowup, arrowdown = true, true
		offset_y = menu.content[player.menu.selected].pos_y - scrollareaheight
		if (((menu.content[#menu.content].pos_y + menu.pos_y) - offset_y) <= (scrollareaheight * 2)) then
			arrowup, arrowdown = true, false
			offset_y = (menu.content[#menu.content].pos_y + menu.pos_y) - (scrollareaheight * 2)
		end
	end
	
	if arrowup then v.drawString(menu.pos_x - 20, menu.pos_y - ((leveltime % 9) / 5), "\x1A", V_YELLOWMAP) end
	if arrowdown then v.drawString(menu.pos_x - 20, ((scrollareaheight * 2)) + ((leveltime % 9) / 5), "\x1B", V_YELLOWMAP) end

	local cursor_y = 0
	for item_index, item in ipairs(menu.content) do
		if (item_index == player.menu.selected) then
			cursor_y = item.pos_y - offset_y
		end
	
		if (((item.pos_y + menu.pos_y) - offset_y) < menu.pos_y) or (((item.pos_y + menu.pos_y) - offset_y) > (scrollareaheight * 2)) then
			continue
		end
		
		local string_position = (menu.pos_y + item.pos_y) - offset_y
		if (item.id == MIT_STRING) then
			local selected_flag = (item_index == player.menu.selected) and V_YELLOWMAP or (item.color and item.color or 0)
			local disabled_flag = (item.flags & MIF_DISABLED) and V_TRANSLUCENT or 0
			local string_flags = disabled_flag|selected_flag
			v.drawString(menu.pos_x, string_position, item.string, V_ALLOWLOWERCASE|string_flags, "left")
			
			if (item.flags & MIF_CVAR_STRING) then
				v.drawString(320 - menu.pos_x, string_position, item.cvar.string, V_ALLOWLOWERCASE|string_flags, "right")
				
				if (item_index == player.menu.selected) then
					v.drawString((((320 - menu.pos_x) - 10) - v.stringWidth(item.cvar.string)) - ((leveltime % 9) / 5), string_position, "\x1C", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
					v.drawString(((320 - menu.pos_x) + 2) + ((leveltime % 9) / 5), string_position, "\x1D", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
				end
			elseif (item.flags & MIF_CVAR_NUMBER) then
				v.drawString(320 - menu.pos_x, string_position, item.cvar.value, V_ALLOWLOWERCASE|string_flags, "right")

				if (item_index == player.menu.selected) then
					v.drawString((((320 - menu.pos_x) - 10) - v.stringWidth(item.cvar.value)) - ((leveltime % 9) / 5), string_position, "\x1C", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
					v.drawString(((320 - menu.pos_x) + 2) + ((leveltime % 9) / 5), string_position, "\x1D", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
				end
			elseif (item.flags & MIF_CVAR_SLIDER) then
				v.drawScaled(((320 - menu.pos_x) - 78) * FRACUNIT, string_position * FRACUNIT, FRACUNIT, v.cachePatch("M_SLIDEL"), string_flags)
				
				for i = 1, 9 do
					v.drawScaled((((320 - menu.pos_x) - 78) + (i * 8)) * FRACUNIT, string_position * FRACUNIT, FRACUNIT, v.cachePatch("M_SLIDEM"), string_flags)
				end
				v.drawScaled((((320 - menu.pos_x) - 78) + 80) * FRACUNIT, string_position * FRACUNIT, FRACUNIT, v.cachePatch("M_SLIDER"), string_flags)
				
				/*local slider_range = (item.cvar.flags & CV_FLOAT) and (item.cvar.defaultvalue * FRACUNIT) else item.cvar.defaultvalue
				if (slider_range ~= item.cvar.value) then	
					
				end*/
			end
		elseif (item.id == MIT_HEADER) then
			local color_flag = (item.color and item.color or V_YELLOWMAP)
			v.drawString(19, string_position, item.string, V_ALLOWLOWERCASE|color_flag, "left")
			v.drawFill(19, string_position + 9, 281, 1, 73);
			v.drawFill(300, string_position + 9, 1, 1, 31);
			v.drawFill(19, string_position + 10, 281, 1, 31);
		end
	end
	v.drawScaled((menu.pos_x - 24) * FRACUNIT, (menu.pos_y + cursor_y) * FRACUNIT, FRACUNIT, v.cachePatch("M_CURSOR"))
end

local function L_RenderMenu(v, player, _)
	if player.menu and player.menu.content and player.menu.show then
		v.fadeScreen(0xFF00, 24)
		J_DoCheckerScroll(v, "TT_ZIGZAG", "TT_CHECKER", -80)
		
		for menu_index, menu in ipairs(player.menu.content) do
			if (menu_index == player.menu.page) then
				if (menu.style == MMT_NORMAL) then
					LM_DrawStandardMenu(v, player, menu)
				elseif (menu.style == MMT_SCROLL) then
					LM_DrawScrollMenu(v, player, menu)
				elseif (menu.style == MMT_CUSTOM) then
					if menu.drawer then
						menu.drawer(v, player, menu)
					end
				end
			end
		end
	end
end
addHook("HUD", L_RenderMenu, "game")