-- Tatsuru's autoexit script -- HUD logic.
-- It's not organized and I don't feel like organizing it

-- Use these time stamps to notify players.
local timestamps = {60, 30, 20, 10, 7, 5, 3, 2, 1}
local remaining, textstart, texttimer, textbaroffset

local cv_autoexit = CV_FindVar("autoexit")

addHook("MapLoad", do
	textstart = false
	remaining, texttimer, textbaroffset = 0, 0, 0
end)

addHook("ThinkFrame", do
	if not multiplayer return end
	if not (gametyperules & GTR_FRIENDLY) return end
	if G_IsSpecialStage(gamemap) return end
	
	local autoexit = cv_autoexit.value * (60*TICRATE)
	
	if leveltime >= autoexit then
		textstart = false
	elseif remaining == 1 then
		textstart = true
	end
	
	for _, t in ipairs(timestamps) do
		if (t * (60*TICRATE)) == (autoexit - leveltime) then
			remaining = t
			textstart = true
			texttimer = 0
			textbaroffset = 0
		end
	end
	
	-- These should tick independently. I don't wanna think what would happen to these in a dedicated server
	textbaroffset = textstart and ($ < 8 and $ + 1 or $) or ($ and $ - 1 or 0)
	texttimer = textstart and $ + 1 or 0
	
	-- Dediserver hack. Just in case.
	if abs(texttimer) >= 9999 then textstart = false end
end)

local function DefaultNotif(v)
	-- Draw the text!
	local str = string.format("  The current level will restart automatically after \x82%s minutes\x80, so \x85Hurry Up\x80!  ", remaining)
	local len = v.stringWidth(str, V_ALLOWLOWERCASE, "thin") + 320
	
	local x = (320 - texttimer)
	local y = (200 - textbaroffset)
	
	v.drawString(x, y, str, V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "thin")
	
	-- Is it over yet?
	if texttimer > len then textstart = false end
end

local function HurryUpText(v, didfinish)
	local color = ((leveltime/15) % 2) and V_REDMAP or V_YELLOWMAP
	local countlogic = ((cv_autoexit.value * (60*TICRATE)) - leveltime + 35)/TICRATE

	local x, y = 258, 166
	local flags = V_ALLOWLOWERCASE|V_SNAPTORIGHT|V_SNAPTOBOTTOM

	local str1 = string.format("Leaving in: \x82%d \x80second%s.", countlogic, (countlogic == 1) and "" or "s") 
	local str2 = string.format("\x82%d \x80second%s left.", countlogic, (countlogic == 1) and "" or "s")

	if didfinish then
		M_DrawBox(v, x-60, y-7, 13, 2, flags)

		v.drawString(x, y+2, "Good Job!", flags|V_SKYMAP, "thin-center")
		v.drawString(x, y+10, str1, flags, "thin-center")
	else
		M_DrawBox(v, x-57, y-9, 12, 3, flags)

		v.drawString(x, y, "Hurry Up!", color|flags, "thin-center")
		v.drawString(x, y+8, "Go to the exit, now!", flags, "thin-center")
		v.drawString(x, y+16, str2, flags, "thin-center")
	end
end

addHook("HUD", function(v, p)
	-- No bar? No service
	if not textbaroffset return end
	
	-- Draw the bar!
	if (remaining ~= 1) then
		local basewidth = v.width()/v.dupx()
		local baseheight = v.height()/v.dupy()
		
		local flags = V_20TRANS|V_SNAPTOLEFT|V_SNAPTOBOTTOM
		local y = (198 - textbaroffset)*FRACUNIT
				
		-- Draw the bar!
		local patch = v.cachePatch("~031")
		local stretch = ((basewidth / patch.width) + 1) * FRACUNIT
		v.drawStretched(0, y, stretch, FRACUNIT, patch, flags)
	end	

	-- No text? No service
	if not textstart return end
	
	-- Which notification to draw?
	local autoexit = cv_autoexit.value * (60*TICRATE)
	if ((autoexit - leveltime) < 60*TICRATE)
		local check = DidFinish(p) and true or false
		HurryUpText(v, check)
	else
		DefaultNotif(v)
	end
end, "game")

addHook("NetVars", function(net)
	remaining = net($)
	textstart = net($)
	texttimer = net($)
	textbaroffset = net($)
end)