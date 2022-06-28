//
-- AFK system
//

local cv_afk_delay = CV_RegisterVar({
	name = "afk_delay",
	defaultvalue = 2,
	flags = CV_NETVAR,
	possiblevalue = {MIN = 2, MAX = 10}
})

local cv_afk_kick = CV_RegisterVar({
	name = "afk_kick",
	defaultvalue = 5,
	flags = CV_NETVAR,
	possiblevalue = {MIN = 5, MAX = 20}
})

// some bars
local P_AFKVariables = function()
	for player in players.iterate do
		player.afk = $ or false
		player.afk_timer = $ or 0
		player.afk_delay = $ or 0
		player.afk_vars =  $ or {}

		if not (player.quittime > 0) then
			player.afk_delay = max($ - 1, 0)
		end
	end
end

local function P_ToggleAFK(player)
	if not (gamestate == GS_LEVEL) then
		CONS_Printf(player, "This can be only used in a level.")
		return
	end
	
	if player.spectator then
		CONS_Printf(player, "Being AFK on spectator mode? You're crazy.")
		return
	end
	
	if player.afk_delay then
		CONS_Printf(player, "Please wait " .. player.afk_delay/TICRATE .. " seconds to continue.")
		return
	end
	
	player.afk = not player.afk
	
	if player.afk then
		if not player.exiting then
			player.exiting = 1
		end
		
		if player.realmo then
			player.afk_vars = {x = player.realmo.x, y = player.realmo.y, z = player.realmo.z, momx = player.realmo.momx, momy = player.realmo.momy, momz = player.realmo.momz}
		end
		chatprint("\x82" .. "* " .. player.name .. "\x82" .. " is now AFK.")
	else
		player.realmo.flags2 = $ & ~(MF2_SHADOW)
		player.afk_timer = 0
		player.exiting = 0
	
		player.afk_vars = {}
		chatprint("\x82" .. "* " .. player.name .. "\x82" .. " is no longer AFK.")
	end
	player.afk_delay = 10*TICRATE
end

local function P_AFKSetup(player)
	if player.afk then
		if player.realmo then
			player.afk_vars = {x = player.realmo.x, y = player.realmo.y, z = player.realmo.z, momx = player.realmo.momx, momy = player.realmo.momy, momz = player.realmo.momz}
		end
		
		player.exiting = 1
	else
		player.afk = false
		player.afk_vars = {}
	end
end

local function P_AFKThink()
	for player in players.iterate do
		if player.afk then
			player.powers[pw_flashing] = 2
			player.powers[pw_nocontrol] = 2
			
			if player.realmo then
				P_TeleportMove(player.realmo, player.afk_vars.x, player.afk_vars.y, player.afk_vars.z)
				
				player.realmo.momx, player.realmo.momy, player.realmo.momz = player.afk_vars.momx, player.afk_vars.momy, player.afk_vars.momz
				
				player.realmo.flags2 = $ | MF2_SHADOW & ~(MF2_DONTDRAW)
				player.pflags = $ | PF_INVIS
			end
			
			--player.realtime = 209999
		end

		if player.realmo and not (player.quittime > 0) then
			local afk_calculate = ((abs(player.realmo.momx) < FRACUNIT) and (abs(player.realmo.momy) < FRACUNIT) and (abs(player.realmo.momz) < FRACUNIT))
			
			if afk_calculate then
				player.afk_timer = $ + 1
			
				if not player.afk and (player.afk_timer == (cv_afk_delay.value * (60*TICRATE))) then
					player.afk_delay = 0
					P_ToggleAFK(player)
					player.afk_delay = 15 * TICRATE
					
					chatprintf(player, "\x82" .. "* You're now AFK for idling for too long.")
				end
				
				if player.afk and (player.afk_timer == (cv_afk_kick.value * (60*TICRATE))) then
					if not (server == player) then
						COM_BufInsertText(server, 'kick ' .. #player .. ' "Idling for too long"')
					end
				end
			else
				player.afk_timer = 0
			end
		end
	end
end

local function P_AFKHud(v, player)
	local x = 160
	local y1, y2 = 16, 168

	if player.afk then
		M_DrawBox(v, x-137, y1-11, 32, 3, 0)
		v.drawString(x, y1, "You're AFK", V_YELLOWMAP|V_ALLOWLOWERCASE, "center")
		v.drawString(x, y1+9, "Type" .. "\x82 " .. "\"afk\"" .. "\x80 on the console again to quit this mode.", V_ALLOWLOWERCASE, "thin-center")

		M_DrawBox(v, x-148, y2-13, 35, 3, 0)
		v.drawString(x, y2, "You are either here because you entered" .. "\x82 " .. "\"afk\"" .. "\x80 on the console,", V_ALLOWLOWERCASE, "thin-center")
		v.drawString(x, y2+8, "or either been out of the game for 2 minutes.", V_ALLOWLOWERCASE, "thin-center")
	end
end

//
// Hookers
//

addHook("PreThinkFrame", P_AFKVariables)

addHook("PlayerSpawn", P_AFKSetup)
addHook("PostThinkFrame", P_AFKThink)
addHook("HUD", P_AFKHud, "game")

COM_AddCommand("afk", P_ToggleAFK)