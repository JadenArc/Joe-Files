/*
	Lugent's Menu System
	Version 1.0
*/

if menu_framework then
	error("Multiple versions of Lugent's Menus are loaded, the loaded addon was disabled to prevent problems.", 0)
	return
end

//
// Constants for everything else
//

-- create sum flags
local createFlags = function(tname, t)
    for i = 1,#t do
        rawset(_G, t[i], 2 ^ (i - 1))
        table.insert(tname, {string = t[i], value = 2 ^ (i - 1)} )
    end
end

-- Keys
rawset(_G, "KEY_UP",	   230)
rawset(_G, "KEY_DOWN",	   238)
rawset(_G, "KEY_LEFT",	   233)
rawset(_G, "KEY_RIGHT",	   235)
rawset(_G, "KEY_ESC",		27)
rawset(_G, "KEY_ENTER",		13)
rawset(_G, "KEY_BACKSPACE",  8)
rawset(_G, "KEY_CONSOLE",	96)

-- Menu types
rawset(_G, "MMT_NORMAL", 0)
rawset(_G, "MMT_SCROLL", 1)
rawset(_G, "MMT_CUSTOM", 2)

-- Menu item types
rawset(_G, "MIT_STRING", 0)
rawset(_G, "MIT_HEADER", 1)

-- Menu item flags
rawset(_G, "MENUITEMFLAGS", {})
createFlags(MENUITEMFLAGS, {
	"MIF_DISABLED",
	"MIF_FUNCTION",
	"MIF_CVAR_STRING",
	"MIF_CVAR_NUMBER"
})

//
// Functions and else
//

rawset(_G, "menu_framework", {})

menu_framework.active = false -- if active

menu_framework.current = -1 -- current menu table
menu_framework.cursor = -1 -- the actual cursor item position
menu_framework.page = -1 -- the actual page on the menu

local function LM_ActiveMenu()
	return menu_framework.active and (menu_framework.current ~= -1) and (gamestate == GS_LEVEL)
end

local function LM_Reset()
	menu_framework.active = false
	menu_framework.current, menu_framework.cursor, menu_framework.page = -1, -1, -1
end

local function LM_CloseMenu()
	if not LM_ActiveMenu() then return end

	input.setMouseGrab(true)
	LM_Reset()
end

local function LM_OpenMenu(menu, page)
	if (page < 1) and (page > #menu) then
		CONS_Printf("LM_OpenMenu(): Tried to open a menu with specified page out of bounds.")
		return
	end
	
	menu_framework.active = true
	menu_framework.page = page
	menu_framework.current = menu
	menu_framework.cursor = menu_framework.current[menu_framework.page].attributes.start
end

local function LM_PrevPage()
	if not LM_ActiveMenu() then return end
	
	if (menu_framework.current[menu_framework.page].attributes.previous.page < 1) then
		LM_CloseMenu()
		return
	end
	
	menu_framework.cursor = menu_framework.current[menu_framework.page].attributes.previous.item
	menu_framework.page = menu_framework.current[menu_framework.page].attributes.previous.page
end

local function LM_GoToPage(page)
	if not LM_ActiveMenu() then return end
	
	if (page < 1) and (page > #menu_framework.current) then
		CONS_Printf("LM_GoToPage(): Tried to go out of bounds.")
		return
	end
	
	menu_framework.page = page
	menu_framework.cursor = menu_framework.current[menu_framework.page].attributes.start
end

local function LM_ExecuteThinker()
	if not LM_ActiveMenu() then return end
	
	if menu_framework.current[menu_framework.page].functions.ticker then
		menu_framework.current[menu_framework.page].functions.ticker(menu_framework.current)
	end
end

local function LM_PressedKey(keyevent, code)
	return (keyevent.num == code)
end

/*local function test_function(menu)
	LM_GoToPage(2)
end

local function test_function2(menu)
	LM_PrevPage()
end

local test_menu = {
	{
		attributes = {
			pos = {30, 30},
			header = {text = "Test Menu", color = V_YELLOWMAP},
			start = {item = 2},
			previous = {page = -1, item = -1},
			style = MMT_NORMAL
		},
		functions = {handler = nil, ticker = nil, drawer = nil},
		content = {
			{id = MIT_HEADER, flags = 0, string = "Test Header", color = 0, func = nil, cvar = nil, pos_y = 0},
			{id = MIT_STRING, flags = 0, string = "Test String", color = 0, func = nil, cvar = nil, pos_y = 12},
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Test Function...", color = 0, func = test_function, cvar = nil, pos_y = 22},
			{id = MIT_STRING, flags = MIF_CVAR_STRING, string = "Test CVar String", color = 0, func = nil, cvar = CV_FindVar("cooplives"), pos_y = 42},
			{id = MIT_STRING, flags = MIF_CVAR_NUMBER, string = "Test CVar Number", color = 0, func = nil, cvar = CV_FindVar("inttime"), pos_y = 52},
			{id = MIT_STRING, flags = MIF_DISABLED, string = "Test Disabled", color = 0, func = nil, cvar = nil, pos_y = 72},
		}
	},
	{
		attributes = {
			pos = {30, 30},
			header = {text = "Top Secret Cheats", color = V_YELLOWMAP},
			start = {item = 2},
			previous = {page = 1, item = 3},
			style = MMT_NORMAL
		},
		functions = {handler = nil, ticker = nil, drawer = nil},
		content = {
			{id = MIT_HEADER, flags = 0, string = "Use with caution", color = 0, func = nil, cvar = nil, pos_y = 0},
			{id = MIT_STRING, flags = 0, string = "Teleport to Area 51...", color = 0, func = nil, cvar = nil, pos_y = 12},
			{id = MIT_STRING, flags = 0, string = "Remove Tails...", color = 0, func = nil, cvar = nil, pos_y = 22},
			{id = MIT_STRING, flags = MIF_FUNCTION, string = "Restart the universe...", color = V_REDMAP, func = test_function2, cvar = nil, pos_y = 102},
		}
	}
}*/

local function LM_ThinkFrame()
	if not LM_ActiveMenu() then return end
	
	input.setMouseGrab(false)
	LM_ExecuteThinker()
end
addHook("PreThinkFrame", LM_ThinkFrame)

local function LM_KeyEvents(keyevent)
	if not LM_ActiveMenu() then return false end
	
	if LM_PressedKey(keyevent, KEY_CONSOLE) then
		return false
	end
		
	if LM_PressedKey(keyevent, KEY_ESC) then
		LM_PrevPage()
		return true
	end
	
	if LM_PressedKey(keyevent, KEY_UP) then
		repeat
			menu_framework.cursor = $ - 1
			if not menu_framework.cursor then
				menu_framework.cursor = #menu_framework.current[menu_framework.page].content
			end
		until (menu_framework.current[menu_framework.page].content[menu_framework.cursor].id ~= MIT_HEADER) and not (menu_framework.current[menu_framework.page].content[menu_framework.cursor].flags & MIF_DISABLED)
	
		S_StartSound(nil, sfx_menu1, consoleplayer)
		return true
	end
			
	if LM_PressedKey(keyevent, KEY_DOWN) then
		repeat
			menu_framework.cursor = $ + 1
			if menu_framework.cursor > #menu_framework.current[menu_framework.page].content then
				menu_framework.cursor = 1
			end
		until (menu_framework.current[menu_framework.page].content[menu_framework.cursor].id ~= MIT_HEADER) and not (menu_framework.current[menu_framework.page].content[menu_framework.cursor].flags & MIF_DISABLED)
	
		S_StartSound(nil, sfx_menu1, consoleplayer)
		return true
	end
		
	if LM_PressedKey(keyevent, KEY_LEFT) then
		if (menu_framework.current[menu_framework.page].content[menu_framework.cursor].flags & (MIF_CVAR_STRING|MIF_CVAR_NUMBER)) then
			COM_BufInsertText(consoleplayer, "add " .. menu_framework.current[menu_framework.page].content[menu_framework.cursor].cvar.name .. " -1")
			S_StartSound(nil, sfx_menu1, consoleplayer)
		end
		return true
	end
		
	if LM_PressedKey(keyevent, KEY_RIGHT) then
		if (menu_framework.current[menu_framework.page].content[menu_framework.cursor].flags & (MIF_CVAR_STRING|MIF_CVAR_NUMBER)) then
			COM_BufInsertText(consoleplayer, "add " .. menu_framework.current[menu_framework.page].content[menu_framework.cursor].cvar.name .. " 1")
			S_StartSound(nil, sfx_menu1, consoleplayer)
		end
		return true
	end
	
	if LM_PressedKey(keyevent, KEY_ENTER) then
		if (menu_framework.current[menu_framework.page].content[menu_framework.cursor].flags & MIF_FUNCTION) then
			if menu_framework.current[menu_framework.page].content[menu_framework.cursor].func
				menu_framework.current[menu_framework.page].content[menu_framework.cursor].func(menu_framework.current)
				S_StartSound(nil, sfx_menu1, consoleplayer)
			end
		end
		return true
	end

	if menu_framework.current[menu_framework.page].functions.handler then
		menu_framework.current[menu_framework.page].functions.handler(keyevent)
		return true
	end
	return true
end
addHook("KeyDown", LM_KeyEvents)

local function JM_DrawMenuTitle(v, menu)
	if not menu.attributes.header then return end
	
	local color_flag = menu.attributes.header.color or 0
	local text = menu.attributes.header.text

	local x = 160 - (v.levelTitleWidth(text) / 2)
	
	if (text:len() > 17) then 
		v.drawString(160, 12, text, color_flag|V_ALLOWLOWERCASE, "center")
	else
		v.drawLevelTitle(x, 5, text, color_flag)
	end
end

local function LM_DrawStandardMenu(v, menu)
	JM_DrawMenuTitle(v, menu)

	local cursor_y = 0
	for item_index, item in ipairs(menu.content) do
		if (item_index == menu_framework.cursor) then
			cursor_y = item.pos_y
		end
		
		if (item.id == MIT_STRING) then
			local selected_flag = (item_index == menu_framework.cursor) and V_YELLOWMAP or (item.color and item.color or 0)
			local disabled_flag = (item.flags & MIF_DISABLED) and V_TRANSLUCENT or 0
			local string_flags = disabled_flag|selected_flag
		
			v.drawString(menu.attributes.pos[1], menu.attributes.pos[2] + item.pos_y, item.string, V_ALLOWLOWERCASE|string_flags, "left")
			
			if (item.flags & MIF_CVAR_STRING) then
				v.drawString(320 - menu.attributes.pos[1], (menu.attributes.pos[2] + item.pos_y), item.cvar.string, V_ALLOWLOWERCASE|string_flags, "right")
				
				if (item_index == menu_framework.cursor) then
					v.drawString((((320 - menu.attributes.pos[1]) - 10) - v.stringWidth(item.cvar.string)) - ((leveltime % 9) / 5), (menu.attributes.pos[2] + item.pos_y), "\x1C", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
					v.drawString(((320 - menu.attributes.pos[1]) + 2) + ((leveltime % 9) / 5), (menu.attributes.pos[2] + item.pos_y), "\x1D", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
				end
		
			elseif (item.flags & MIF_CVAR_NUMBER) then
				v.drawString(320 - menu.attributes.pos[1], (menu.attributes.pos[2] + item.pos_y), item.cvar.value, V_ALLOWLOWERCASE|string_flags, "right")

				if (item_index == menu_framework.cursor) then
					v.drawString((((320 - menu.attributes.pos[1]) - 10) - v.stringWidth(item.cvar.value)) - ((leveltime % 9) / 5), (menu.attributes.pos[2] + item.pos_y), "\x1C", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
					v.drawString(((320 - menu.attributes.pos[1]) + 2) + ((leveltime % 9) / 5), (menu.attributes.pos[2] + item.pos_y), "\x1D", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
				end	
			end
	
		elseif (item.id == MIT_HEADER) then
			local color_flag = (item.color or V_YELLOWMAP)
			v.drawString(19, menu.attributes.pos[2] + item.pos_y, item.string, V_ALLOWLOWERCASE|color_flag, "left")
			v.drawFill(19, (menu.attributes.pos[2] + item.pos_y) + 9, 281, 1, 73);
			v.drawFill(300, (menu.attributes.pos[2] + item.pos_y) + 9, 1, 1, 31);
			v.drawFill(19, (menu.attributes.pos[2] + item.pos_y) + 10, 282, 1, 31);
		end
	end
	v.drawScaled((menu.attributes.pos[1] - 24) * FRACUNIT, (menu.attributes.pos[2] + cursor_y) * FRACUNIT, FRACUNIT, v.cachePatch("M_CURSOR"))
end

local scrollareaheight = 88
local function LM_DrawScrollMenu(v, menu)
	JM_DrawMenuTitle(v, menu)

	local arrowup, arrowdown = false, false
	if (menu.content[#menu.content].pos_y > scrollareaheight) then
		arrowup, arrowdown = false, true
	end
	
	local offset_y = 0
	if (menu.content[menu_framework.cursor].pos_y >= scrollareaheight) then
		arrowup, arrowdown = true, true
		offset_y = menu.content[menu_framework.cursor].pos_y - scrollareaheight
		if (((menu.content[#menu.content].pos_y + menu.attributes.pos[2]) - offset_y) <= (scrollareaheight * 2)) then
			arrowup, arrowdown = true, false
			offset_y = (menu.content[#menu.content].pos_y + menu.attributes.pos[2]) - (scrollareaheight * 2)
		end
	end
	
	if arrowup then
		v.drawString(menu.attributes.pos[1] - 20, menu.attributes.pos[2] - ((leveltime % 9) / 5), "\x1A", V_YELLOWMAP)
	end
	
	if arrowdown then
		v.drawString(menu.attributes.pos[1] - 20, ((scrollareaheight * 2)) + ((leveltime % 9) / 5), "\x1B", V_YELLOWMAP)
	end

	local cursor_y = 0
	for item_index, item in ipairs(menu.content) do
		if (item_index == menu_framework.cursor) then
			cursor_y = item.pos_y - offset_y
		end
	
		if (((item.pos_y + menu.attributes.pos[2]) - offset_y) < menu.attributes.pos[2]) or (((item.pos_y + menu.attributes.pos[2]) - offset_y) > (scrollareaheight * 2)) then
			continue
		end
		
		local string_position = (menu.attributes.pos[2] + item.pos_y) - offset_y
		
		if (item.id == MIT_STRING) then
			local selected_flag = (item_index == menu_framework.cursor) and V_YELLOWMAP or (item.color and item.color or 0)
			local disabled_flag = (item.flags & MIF_DISABLED) and V_TRANSLUCENT or 0
			local string_flags = disabled_flag|selected_flag
		
			v.drawString(menu.attributes.pos[1], string_position, item.string, V_ALLOWLOWERCASE|string_flags, "left")
			
			if (item.flags & MIF_CVAR_STRING) then
				v.drawString(320 - menu.attributes.pos[1], string_position, item.cvar.string, V_ALLOWLOWERCASE|string_flags, "right")
				
				if (item_index == menu_framework.cursor) then
					v.drawString((((320 - menu.attributes.pos[1]) - 10) - v.stringWidth(item.cvar.string)) - ((leveltime % 9) / 5), string_position, "\x1C", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
					v.drawString(((320 - menu.attributes.pos[1]) + 2) + ((leveltime % 9) / 5), string_position, "\x1D", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
				end
		
			elseif (item.flags & MIF_CVAR_NUMBER) then
				v.drawString(320 - menu.attributes.pos[1], string_position, item.cvar.value, V_ALLOWLOWERCASE|string_flags, "right")

				if (item_index == menu_framework.cursor) then
					v.drawString((((320 - menu.attributes.pos[1]) - 10) - v.stringWidth(item.cvar.value)) - ((leveltime % 9) / 5), string_position, "\x1C", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
					v.drawString(((320 - menu.attributes.pos[1]) + 2) + ((leveltime % 9) / 5), string_position, "\x1D", V_YELLOWMAP|V_ALLOWLOWERCASE|string_flags)
				end
			end
		
		elseif (item.id == MIT_HEADER) then
			local color_flag = (item.color and item.color or V_YELLOWMAP)
			v.drawString(19, string_position, item.string, V_ALLOWLOWERCASE|color_flag, "left")
			v.drawFill(19, string_position + 9, 281, 1, 73);
			v.drawFill(300, string_position + 9, 1, 1, 26);
			v.drawFill(19, string_position + 10, 281, 1, 26);
		end
	end
	v.drawScaled((menu.attributes.pos[1] - 24) * FRACUNIT, (menu.attributes.pos[2] + cursor_y) * FRACUNIT, FRACUNIT, v.cachePatch("M_CURSOR"))
end

local function LM_RenderMenu(v)
	if not LM_ActiveMenu() then return end

	v.fadeScreen(0xFF00, 24)

	for menu_index, menu in ipairs(menu_framework.current) do
		if (menu_index == menu_framework.page) then
			if (menu.attributes.style == MMT_NORMAL) then
				LM_DrawStandardMenu(v, menu)
			elseif (menu.attributes.style == MMT_SCROLL) then
				LM_DrawScrollMenu(v, menu)
			elseif (menu.attributes.style == MMT_CUSTOM) then
				if menu.functions.drawer then
					menu.functions.drawer(v, menu)
				end
			end
		end
	end
end
addHook("HUD", LM_RenderMenu, "game")

rawset(_G, "LM_PressedKey", LM_PressedKey)
rawset(_G, "LM_GoToPage", LM_GoToPage)
rawset(_G, "LM_PrevPage", LM_PrevPage)
rawset(_G, "LM_OpenMenu", LM_OpenMenu)
rawset(_G, "LM_CloseMenu", LM_CloseMenu)
rawset(_G, "LM_ActiveMenu", LM_ActiveMenu)

rawset(_G, "LM_DrawScrollMenu", LM_DrawScrollMenu)
rawset(_G, "LM_DrawStandardMenu", LM_DrawStandardMenu)