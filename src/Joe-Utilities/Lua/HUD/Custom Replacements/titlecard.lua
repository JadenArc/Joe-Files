//
// Custom Titlecard
// By Jaden
//
// This was total pain
//

local title_tics = 0

local T_TitleThink = function()
	if (paused) then return end
	
	title_tics = $ + 1
end

local TH_DrawTitle = function(v, player, ticker, endticker)
	local level_title = mapheaderinfo[gamemap].lvlttl
	local sub_title = mapheaderinfo[gamemap].subttl
	local act_number = mapheaderinfo[gamemap].actnum

	local has_zone = (mapheaderinfo[gamemap].levelflags & LF_NOZONE)

	//
	// Run all the stuff correctly.
	//

	T_TitleThink()

	//
	// Sum zigzags (copypaste of intermission.lua)
	//

	local zigzag, zztext, zztext_flip, colormap = V_GetZigPatch(v, player)

	local zz_offs = title_tics % zigzag.height
	local zt_offs = title_tics % zztext.height
	local zf_offs = title_tics % zztext_flip.height

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
	// Level Title and act number
	//

	V_CenterLevelTitle(v, 10, level_title)
	
	if not (has_zone) then
		V_CenterLevelTitle(v, 32, "Zone")
	else
		V_CenterLevelTitle(v, 32, "The Act")
	end

	if (act_number) then
		v.drawString(164, 172, "Act", V_YELLOWMAP|V_ALLOWLOWERCASE, "right")
		V_DrawLevelActNum(v, 170, 162, act_number)
	end

	//
	// Subtitle
	//

	v.drawString(160, 60, sub_title, V_ALLOWLOWERCASE, "center")
end

local T_TitleDrawer = function(v, player, ticker, endticker)
	hud.disable("stagetitle")

	if (ticker >= endticker) then return end

	TH_DrawTitle(v, player, ticker, endticker)
end
addHook("HUD", T_TitleDrawer, "titlecard")