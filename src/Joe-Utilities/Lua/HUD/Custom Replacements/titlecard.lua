//
-- Custom Titlecard
-- By Jaden
--
-- This was total pain
//

local title_tics = 0
local zig_tics = 0

addHook("MapChange", do
	title_tics = 0
	zig_tics = 0
end)

local T_TitleThink = function()
	if (paused) then return end

	zig_tics = $ + 1

	-- ticker really does suck on syncing, so lets use zig_tics instead!
	if (zig_tics <= 60) then
		title_tics = min($ + 1, 50)
	else
		title_tics = max(0, $ - 1)
	end
end

local TH_DrawTitle = function(v, player)
	local level_title = mapheaderinfo[gamemap].lvlttl
	local sub_title = mapheaderinfo[gamemap].subttl
	local act_number = mapheaderinfo[gamemap].actnum

	local has_zone = not (mapheaderinfo[gamemap].levelflags & LF_NOZONE)

	//
	// Run all the stuff correctly.
	//

	T_TitleThink()

	local anim = JoeBase.GetEasingTics(title_tics)
	local title_anims = {
		[0] = ease.inoutcubic(anim, -200, 0),
		[1] = ease.inoutcubic(anim, 400, 0)
	}

	//
	// Sum zigzags (copypaste of intermission.lua)
	//

	local zigzag = v.cachePatch("J_ZIGZAG")
	local zztext = v.cachePatch("J_ZZTEXT")

	local colormap = v.getColormap(TC_DEFAULT, (player.skincolor) or R_GetColorByName(CV_FindVar("color").value))

	local zz_offs = zig_tics % zigzag.height
	local zt_offs = zig_tics % zztext.height

	-- Zigzags --
	
	v.draw(title_anims[0], 				  -(zz_offs), zigzag, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.draw(title_anims[0], (zigzag.height - zz_offs), zigzag, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	
	v.draw(320 + title_anims[1], 			 	 (zz_offs), zigzag, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)
	v.draw(320 + title_anims[1], (-zigzag.height + zz_offs), zigzag, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)

	-- "Sonic Robo Blast 2" --

	v.draw(title_anims[0], 				    (zt_offs), zztext, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.draw(title_anims[0], (-zztext.height + zt_offs), zztext, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)

	v.draw(320 + title_anims[1], 			    -(zt_offs), zztext, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)
	v.draw(320 + title_anims[1], (zztext.height - zt_offs), zztext, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)

	//
	// Level Title and act number
	//

	local title_y = 40
	local act_y = 132

	V_AlignLevelTitle(v, 160, title_y + title_anims[0], level_title, "center")
	
	if (has_zone) then
		V_AlignLevelTitle(v, 160, (title_y + 22) + title_anims[0], "Zone", "center")
	end

	if (act_number) then
		local actpat = v.cachePatch("J_ACTPAT")
		v.draw(151 + title_anims[1], act_y, actpat, 0, colormap)

		local actnum_center = V_LevelActNumWidth(v, act_number) / 2
		V_DrawLevelActNum(v, (160 - actnum_center) - title_anims[1], act_y, act_number)
	end

	//
	// Subtitle
	//

	v.drawString(160, (title_y + 50) + title_anims[0], sub_title, V_ALLOWLOWERCASE, "center")
end

local T_TitleDrawer = function(v, player, ticker, endticker)
	hud.disable("stagetitle")

	if (ticker >= endticker) then return end

	TH_DrawTitle(v, player)
end
addHook("HUD", T_TitleDrawer, "titlecard")