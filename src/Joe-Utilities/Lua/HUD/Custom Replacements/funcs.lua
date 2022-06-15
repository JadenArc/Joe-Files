//
-- Functions for both Titlecard and Intermission Screens
-- By Jaden
//

// yeah.
local function V_LevelActNumWidth(v, num)
	local result = 0

	// cache act numbers for level titles
	local ttlnum = {}
	
	for i = 0, 10 do
		local buffer = string.format("TTL%.2d", i)
		ttlnum[i] = v.cachePatch(buffer)
	end

	if (num == 0) then
		result = ttlnum[num].width
	end

	while (num > 0 and num <= 99) do
		result = $ + ttlnum[num % 10].width
		num = $ / 10
	end

	return result
end
rawset(_G, "V_LevelActNumWidth", V_LevelActNumWidth)

-- flags aint necessary for this one.
local function V_DrawLevelActNum(v, x, y, num)
	if (num > 99) then return end

	// cache act numbers for level titles
	local ttlnum = {}
	
	for i = 0, 10 do
		local buffer = string.format("TTL%.2d", i)
		ttlnum[i] = v.cachePatch(buffer)
	end

	//
	// drawing section.
	//

	while (num > 0) do
		// if there are two digits, draw second digit first
		if (num > 9)
			v.draw(x + (V_LevelActNumWidth(v, num) - V_LevelActNumWidth(v, num % 10)), y, ttlnum[num % 10], 0)
		
		// otherwise, do the thing.
		else
			v.draw(x, y, ttlnum[num], 0)
		end

		num = $ / 10
	end
end
rawset(_G, "V_DrawLevelActNum", V_DrawLevelActNum)

-- another shortcut.
local function V_AlignLevelTitle(v, x, y, str, type)
	local align = v.levelTitleWidth(str)

	if (type == "right")
		x = $ - align
	elseif (type == "center")
		x = $ - (align / 2)
	else
		return v.drawLevelTitle(x, y, str, 0)
	end

	v.drawLevelTitle(x, y, str, 0)
end
rawset(_G, "V_AlignLevelTitle", V_AlignLevelTitle)

-- true
local function V_DrawAlignedPatch(v, x, y, patch, flags, align)
	flags = $ or 0

	local offset = 0

	if (align == "center") then
		offset = patch.width / 2
	elseif (align == "right")
		offset = patch.width
	end

	v.draw(x - offset, y, patch, flags, nil)
end
rawset(_G, "V_DrawAlignedPatch", V_DrawAlignedPatch)