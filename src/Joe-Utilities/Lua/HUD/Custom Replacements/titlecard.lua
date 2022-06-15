//
-- Custom Titlecard
-- By Jaden
--
-- This was total pain
//

local title_tics = 0

addHook("MapChange", do title_tics = 0 end)

local T_TitleThink = function()
	if (paused) then return end
	
	title_tics = $ + 1
end

local TH_DrawTitle = function(v, player, ticker, endticker)
	local level_title = mapheaderinfo[gamemap].lvlttl
	local sub_title = mapheaderinfo[gamemap].subttl
	local act_number = mapheaderinfo[gamemap].actnum

	local has_zone = not (mapheaderinfo[gamemap].levelflags & LF_NOZONE)

	//
	// Run all the stuff correctly.
	//

	T_TitleThink()

	//
	// Sum zigzags (copypaste of intermission.lua)
	//

	local zigzag = v.cachePatch("J_ZIGZAG")
	local zztext = v.cachePatch("J_ZZTEXT")

	local colormap = v.getColormap(TC_DEFAULT, (player.skincolor) or R_GetColorByName(CV_FindVar("color").value))

	local zz_offs = title_tics % zigzag.height
	local zt_offs = title_tics % zztext.height

	-- Zigzags --
	
	v.draw(0, 				 -(zz_offs), zigzag, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.draw(0, (zigzag.height - zz_offs), zigzag, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	
	v.draw(320, 				 (zz_offs), zigzag, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)
	v.draw(320, (-zigzag.height + zz_offs), zigzag, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)

	-- "Sonic Robo Blast 2" --

	v.draw(0, 				   (zt_offs), zztext, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.draw(0, (-zztext.height + zt_offs), zztext, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)

	v.draw(320, 			   -(zt_offs), zztext, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)
	v.draw(320, (zztext.height - zt_offs), zztext, V_SNAPTORIGHT|V_SNAPTOTOP|V_FLIP, colormap)

	//
	// Level Title and act number
	//

	local title_y = 40
	local act_y = 132

	V_AlignLevelTitle(v, 160, title_y, level_title, "center")
	
	if (has_zone) then
		V_AlignLevelTitle(v, 160, title_y + 22, "Zone", "center")
	end

	if (act_number) then
		local actpat = v.cachePatch("J_ACTPAT")
		v.draw(151, act_y, actpat, 0, colormap)

		local actnum_center = V_LevelActNumWidth(v, act_number) / 2
		V_DrawLevelActNum(v, 160 - actnum_center, act_y, act_number)
	end

	//
	// Subtitle
	//

	v.drawString(160, title_y + 50, sub_title, V_ALLOWLOWERCASE, "center")
end

local T_TitleDrawer = function(v, player, ticker, endticker)
	hud.disable("stagetitle")

	if (ticker >= endticker) then return end

	TH_DrawTitle(v, player, ticker, endticker)
end
addHook("HUD", T_TitleDrawer, "titlecard")