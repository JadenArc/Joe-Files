//
// Functions for both Titlecard and Intermission Screens
// By Jaden
//

-- shortcut.
local function V_GetZigPatch(v, player)
	local zigzag = v.cachePatch("J_ZIGZAG")
	
	local zigzag_text, zigzag_text_flip, colormap;

	if not (mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE)
		zigzag_text = v.cachePatch("J_ZZTEXT")
		zigzag_text_flip = v.cachePatch("J_ZZTEXTF")

		colormap = v.getColormap(TC_DEFAULT, player.skincolor)
	else
		zigzag_text = v.cachePatch("JW_ZZTEXT")
		zigzag_text_flip = v.cachePatch("JW_ZZTEXTF")

		colormap = v.getColormap(TC_DEFAULT, SKINCOLOR_RED)
	end

	return zigzag, zigzag_text, zigzag_text_flip, colormap
end
rawset(_G, "V_GetZigPatch", V_GetZigPatch)

-- flags aint necessary for this one.
local function V_DrawLevelActNum(v, x, y, num, center)
	if (num > 99) then return end

	// cache act numbers for level titles
	local ttlnum = {}
	
	for i = 0, 10 do
		local buffer = string.format("TTL%.2d", i)
		ttlnum[i] = v.cachePatch(buffer)
	end

	// yeah.
	local function V_LevelActNumWidth(knum)
		local result = 0

		if (knum == 0) then
			result = ttlnum[knum].width
		end

		while (knum > 0 and knum <= 99) do
			result = $ + ttlnum[knum % 10].width
			knum = $ / 10
		end

		return result
	end

	//
	// drawing section.
	//

	while (num > 0) do
		// if there are two digits, draw second digit first
		if (num > 9)
			v.draw(x + (V_LevelActNumWidth(num) - V_LevelActNumWidth(num % 10)), y, ttlnum[num % 10], 0)
		
		// otherwise, do the thing.
		else
			v.draw(x, y, ttlnum[num], 0)
		end

		num = $ / 10
	end
end
rawset(_G, "V_DrawLevelActNum", V_DrawLevelActNum)

-- another shortcut.
local function V_CenterLevelTitle(v, y, str)
	local center = v.levelTitleWidth(str) / 2

	v.drawLevelTitle(160 - center, y, str, 0)
end
rawset(_G, "V_CenterLevelTitle", V_CenterLevelTitle)