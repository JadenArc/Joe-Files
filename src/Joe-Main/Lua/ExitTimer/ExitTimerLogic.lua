-- Tatsuru's autoexit script -- player logic.
-- It's not organized and I don't feel like organizing it

freeslot("sfx_hurrup")
sfxinfo[sfx_hurrup].caption = "Hurry Up!"

local cv_autoexit = CV_RegisterVar({
	name = "autoexit", 
	defaultvalue = "5",
	flags = CV_NETVAR | CV_CALL | CV_NOINIT, 
	PossibleValue = {MIN = 2, MAX = 60},
	func = function(var)
		if (var.changed) then
			local message = ""

			-- if we are on a level, restart it so it can be pretty.
			if (gamestate == GS_LEVEL) then
				message = "Restarting level to see the proper results..." 
				COM_BufInsertText(server, "wait 45; map " .. G_BuildMapName(gamemap))
				
			-- otherwise, just print a message.
			else
				message = "Please enter a level to see the results."
			end
			
			print("Autoexit's value changed! \x82" .. message)
			S_StartSound(nil, sfx_addfil)
		end
	end
})

local gameovercounter = 0
local timeover = false

addHook("MapLoad", do 
	gameovercounter = 0
	timeover = false
end)

local function TimeOver_Ticker()
	if not (multiplayer or netgame) then return end
	if not (gametyperules & GTR_FRIENDLY) then return end
		
	local autoexit = cv_autoexit.value * (60*TICRATE)
	local autotime = leveltime - autoexit
	
	if (autoexit - leveltime) == 60*TICRATE then
		S_StartSound(nil, sfx_hurrup) 
	end
	
	if (leveltime >= autoexit) then
		if (autotime >= 112) then gameovercounter = $ + 1 end

		if (autotime == 1) then
			P_StartQuake(76*FRACUNIT, 12)

			S_StartSound(nil, sfx_s3k9b)
			S_ChangeMusic("_GOVER", false, nil, 0, 0, MUSICRATE*3, 0)

			stoppedclock = true
			timeover = true

		elseif (autotime >= 370) then
			G_SetCustomExitVars(gamemap, 2)
			G_ExitLevel()
		end
	end
end

local function PlayerOver_Ticker(player)
	local autoexit = cv_autoexit.value * (60*TICRATE)
	
	for player in players.iterate do
		local mo = player.mo
		
		if DidFinish(player) then continue end

		if (timeover) then
			mo.momx, mo.momy, mo.momz = 0, 0, 0
			mo.state = S_PLAY_PAIN

			player.powers[pw_nocontrol] = 2
		end
	end
end

addHook("PreThinkFrame", TimeOver_Ticker)
addHook("PostThinkFrame", PlayerOver_Ticker)

addHook("HUD", function(v, player)
	local autoexit = cv_autoexit.value * (60*TICRATE)

	if not ((leveltime - autoexit) >= 108) then return end

	local time = v.cachePatch("SLIDTIME")
	local over = v.cachePatch("SLIDOVER")
	
	local i = min(6*gameovercounter, 160)
	
	v.draw(i - 8, 		100, time)
	v.draw(320 + 8 - i, 100, over)
end, "game")