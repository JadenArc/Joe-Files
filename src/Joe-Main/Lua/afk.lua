//
-- AFK system
//

local cv_afkdelay = CV_RegisterVar({
	name = "afk_delay",
	defaultvalue = 2,
	flags = CV_NETVAR,
	possiblevalue = {MIN = 2, MAX = 10}
})

local cv_afkkick = CV_RegisterVar({
	name = "afk_kick",
	defaultvalue = 5,
	flags = CV_NETVAR,
	possiblevalue = {MIN = 5, MAX = 20}
})

// LOLXD
local function not_moving(ex)
	return (abs(ex) < FRACUNIT)
end

local function intTo60Minutes(a, b)
	return (a == (b * (60 * TICRATE)))
end

// some bars
local P_AFKVariables = function()
	for player in players.iterate do
		player.afk = $ or {
			enabled = false,
			--delay = 0,
			total_time = 0,
			previous = {}
		}
	end
end
addHook("PreThinkFrame", P_AFKVariables)

local function P_ToggleAFK(player)
	if not (gamestate == GS_LEVEL) then
		CONS_Printf(player, "This can be only used in a level.")
		return
	end
	
	if (player.spectator) then
		CONS_Printf(player, "Your are trying to be AFK on spectator mode? That's crazy!")
		return
	end

	local mo = player.realmo
	player.afk.enabled = not $

	if (player.afk.enabled) then
		if (mo) then
			player.afk.previous = {
				x = mo.x,
				y = mo.y,
				z = mo.z,
				momx = mo.momx,
				momy = mo.momy,
				momz = mo.momz
			}
		end
		
		chatprint("\x82* \x80" .. player.name .. "\x82 is now AFK.")
	else
		player.afk.previous = {}
		chatprint("\x82* \x80" .. player.name .. "\x82 is no longer AFK.")
	end
end
COM_AddCommand("afk", P_ToggleAFK)

local function P_AFKSetup(player)
	local mo = player.realmo

	if not (player.afk) then return end

	if (player.afk.enabled) and (mo) then
		player.afk.previous = {
			x = mo.x,
			y = mo.y,
			z = mo.z,
			momx = mo.momx,
			momy = mo.momy,
			momz = mo.momz
		}
	else
		player.afk.enabled = false
		player.afk.previous = {}
	end
end
addHook("PlayerSpawn", P_AFKSetup)

local function P_AFKThink()
	for player in players.iterate do
		local mo = player.realmo

		if (player.afk.enabled) then
			player.powers[pw_flashing] = 2
			player.powers[pw_nocontrol] = 2

			local previous = player.afk.previous
			
			if (mo) then
				P_TeleportMove(mo, previous.x, previous.y, previous.z)
				
				mo.momx, mo.momy, mo.momz = previous.momx, previous.momy, previous.momz
				
				mo.flags2 = $ | MF2_SHADOW
				player.pflags = $ | PF_INVIS
			end
		end

		if (mo and not (player.quittime > 0)) then
			// XDLOL		
			if (not_moving(mo.momx) and not_moving(mo.momy) and not_moving(mo.momz)) then
				player.afk.total_time = $ + 1
			
				if (not player.afk.enabled) and intTo60Minutes(player.afk.total_time, cv_afkdelay.value) then
					P_ToggleAFK(player)
					
					chatprintf(player, "\x82" .. "* You're now AFK for idling for too long.")
				end
				
				if (player.afk.enabled) and intTo60Minutes(player.afk.total_time, cv_afkkick.value) then
					if not (server == player) then
						COM_BufInsertText(server, 'kick ' .. #player .. ' "Idling for too long"')
					end
				end
			else
				player.afk.total_time = 0
			end
		end
	end
end
addHook("PostThinkFrame", P_AFKThink)

local afk_ticker = 0
local function P_AFKHud(v, player)
	local x = 160
	local y1, y2 = 16, 168

	if (player.afk.enabled) then
		afk_ticker = min($ + 1, TICRATE)
	else
		afk_ticker = max(0, $ - 1)
	end

	local animation = (FRACUNIT / TICRATE) * max(min(afk_ticker, TICRATE), 0)
	local anims = {
		[0] = ease.inoutback(animation, -320, y1),
		[1] = ease.inoutback(animation, 320, y2)
	}

	M_DrawBox(v, x-137, anims[0] - 11, 32, 3, 0)
	v.drawString(x, anims[0], "You're AFK.", V_YELLOWMAP|V_ALLOWLOWERCASE, "center")
	v.drawString(x, anims[0] + 9, "Type\x82 \"afk\" \x80on the console again to quit this mode.", V_ALLOWLOWERCASE, "thin-center")

	M_DrawBox(v, x-148, anims[1] - 13, 35, 3, 0)
	v.drawString(x, anims[1], "You are either here because you entered\x82 \"afk\" \x80on the console,", V_ALLOWLOWERCASE, "thin-center")
	v.drawString(x, anims[1] + 8, "or either been out of the game for 2 minutes.", V_ALLOWLOWERCASE, "thin-center")
end
addHook("HUD", P_AFKHud, "game")