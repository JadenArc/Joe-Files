-- admintools.lua and funtools.lua being merged with a rewrite or recreation

-- something.
local onlylevel = "You must be in a level to use this."

//
-- Let's start with the admin-only commands.
// 

-- emeralds, lol...
CV_RegisterVar({
	name = "emeralds", 
	defaultvalue = "No",
	flags = CV_NETVAR|CV_CALL|CV_NOINIT,
	possiblevalue = CV_YesNo, 
	func = function(var)
		local emflags = EMERALD1|EMERALD2|EMERALD3|EMERALD4|EMERALD5|EMERALD6|EMERALD7

		if var.value == 1 then
			emeralds = $ | (emflags)
			S_StartSound(nil, sfx_cgot)
			print("The emeralds were" .. "\x8B spawned!" .. "\x80 Now you can be super.")

		elseif var.value == 0 then
			emeralds = $ & ~(emflags)
			S_StartSound(nil, sfx_lose)
			print("The emeralds suddenly" .. "\x85 vanished!" .. "\x80 Some wacky admin did it...")
		end
	end
})

-- Kill command, admins can kill players if they want to.
local function CMD_KillCommand(player, target)
    if target == nil then
        CONS_Printf(player, "kill <node>: Kills the node. (Use 'nodes' on the console to see which nodes are which.)")
        return
    end

    if not player.mo then
		CONS_Printf(player, "You don't exist, so you can't kill players for fun.")
		return
	end

    if (target == "all") then
    	for allplayers in players.iterate do
    		if not JoeBase.IsValid(allplayers.mo) then
    			CONS_Printf(player, "This can't be executed! (some players may be dead?)")
    			return
    		end

    		if (allplayers.mo.eflags & MFE_UNDERWATER) then
				P_DamageMobj(allplayers.mo, nil, nil, 1, DMG_DROWNED)
			else
				P_DamageMobj(allplayers.mo, nil, nil, 1, DMG_INSTAKILL)
			end
    	end
    	print(JoeBase.GetPlayerName(player, false, false) .. "\x80 killed all players!")
    	return
    end

    target = tonumber(target)

    if (target > 32 or target < 0) then return end

     if players[target] == nil then 
    	CONS_Printf(player, "That player doesn't exist! Aborting...")
    	return
    end

	target = players[target]

    if (target.pflags & PF_GODMODE) then
        target.pflags = $ & ~(PF_GODMODE)
    end

    if target.mo then
    	if (target.mo.eflags & MFE_UNDERWATER) then
			P_DamageMobj(target.mo, nil, nil, 1, DMG_DROWNED)
		else
			P_DamageMobj(target.mo, nil, nil, 1, DMG_INSTAKILL)
		end
    end
end
COM_AddCommand("kill", CMD_KillCommand, COM_ADMIN)

-- dofor, executes commands on other player's console. Not intended for bad use.
local function CMD_DoforCommand(player, arg1, arg2)
    if (arg1 == nil) then
        CONS_Printf(player, 'dofor <node/all/server> <command>: Inserts a command on the selected node.')
        return
    end
	
	if (arg2 == nil) then
		CONS_Printf(player, "Please supply a console command to make dofor work correctly.")
		return
	end

    if (arg1 == "all") then
        for player2 in players.iterate do
            COM_BufInsertText(player2, arg2)
        end
        return
    end		

    if (arg1 == "server") then
    	COM_BufInsertText(server, arg2)
    	return
    end

    arg1 = tonumber(arg1)

    if (arg1 == nil) or (arg1 > 32 or arg1 < 0) then return end

    arg1 = players[arg1]

    COM_BufInsertText(arg1, arg2)
end
COM_AddCommand('dofor', CMD_DoforCommand, COM_ADMIN)

-- goto, go to a player's coordinates.
local function CMD_GotoCommand(player, target)
    if target == nil then
        CONS_Printf(player, "goto <node>: Goes to the given player's coordinates")
        return
    end

    if not player.mo then
		CONS_Printf(player, "You don't exist, so you can't teleport to other players now.")
		return
	end

    target = tonumber(target)

    if target > 32 or target < 0 or target == nil then return end

    target = players[target]

    if JoeBase.IsValid(player.mo) and JoeBase.IsValid(target.mo) then
        P_TeleportMove(player.mo, target.mo.x, target.mo.y, target.mo.z)
		
		P_FlashPal(player, PAL_MIXUP, 10)
		S_StartSound(player.realmo, sfx_litng1) -- again
    end
end
COM_AddCommand('goto', CMD_GotoCommand, 1)

-- rally, teleport every player to your location.
local function CMD_RallyCommand(player)
	if not player.mo then
		CONS_Printf(player, "You don't exist, so players can't teleport to you now.")
		return
	end
	
	for player2 in players.iterate do
		if JoeBase.IsValid(player.mo) and JoeBase.IsValid(player2.mo) then
			if player2 ~= player then
				P_TeleportMove(player2.mo, player.mo.x, player.mo.y, player.mo.z)
				P_FlashPal(player2, PAL_MIXUP, 10)
				S_StartSound(player.realmo, sfx_mixup) -- we do trolling
			end
		end
	end
	
	print(JoeBase.GetPlayerName(player, false, false) .. "\x80 rallied everyone to them.")
end
COM_AddCommand("rally", CMD_RallyCommand, COM_ADMIN)

-- changemus, exactly what is says on the tin.
local function CMD_ChangeMusicCommand(player, music)
    if music == nil then
        CONS_Printf(player, 'changemus <musicid>: Changes music for everyone.')
        return
    end

    music = string.upper(music)

    for player2 in players.iterate do
        COM_BufInsertText(player2, 'tunes ' .. music)
    end

    chatprint(JoeBase.GetPlayerName(player, true, false) .. "\x80 has changed the music to \x86" .. music)
end
COM_AddCommand('changemus', CMD_ChangeMusicCommand, 1)

-- scaleto, troll someone by changing its size
local function CMD_ScaleToCommand(p, target, scale)
	local nScale = FloatNumber(scale)

    if target == nil then
        CONS_Printf(p, "scale <target> <value>: Make someone bigger or smaller")
        return
    end

	if not nScale then
		CONS_Printf(p, "Please supply a value to make this work properly.")
		return
	end
	
	if target == "all" then
		for all in players.iterate do
		   if JoeBase.IsValid(all.mo) then
				all.mo.destscale = nScale
			end
		end
		return
	end

    target = tonumber(target)

    if target > 32 or target < 0 then return end

    target = players[target]

    if JoeBase.IsValid(target.mo) then
		target.mo.destscale = nScale
	end
end
COM_AddCommand("scaleto", CMD_ScaleToCommand, 1)

-- spawnobject, self-explanatory.
local function CMD_SpawnobjectCommand(player, object)
    if object == nil then
        CONS_Printf(player, "spawnobject" .. "\x82 <object>" .. "\x80" .. ": Spawns object via MT_* \n" ..
							"Go to https://wiki.srb2.org/wiki/List_of_Object_types to get a list of Object Types."
		)
        return
    end

    object = _G["MT_" .. string.upper(object)]
	
	if not object then
		CONS_Printf(player, "This object doesn't exist! (maybe mistyping?)")
		return
	end

    if JoeBase.IsValid(player.mo) then
    	local y = 135 * sin(player.drawangle)
    	local x = 135 * cos(player.drawangle)

		local result = P_SpawnMobjFromMobj(player.mo, x, y, 8*FRACUNIT, object)
 		
 		result.angle = player.mo.angle
		P_SetScale(result, player.mo.scale)
    end
end
COM_AddCommand('spawnobject', CMD_SpawnobjectCommand, 1)

-- killallenemies, you know the rules.
local function CMD_KillEnemiesCommand(player)
    for object in mobjs.iterate("mobj") do
        if (object.flags & MF_ENEMY) or (object.flags & MF_BOSS) then
            P_KillMobj(object, nil, player.mo)
        end
    end
end
COM_AddCommand('killallenemies', CMD_KillEnemiesCommand, 1)

-- print, and so do i.
local function CMD_DoPrint(player, typeof, message)
	if not typeof then
		CONS_Printf(player, "print <type> <message>: print something to the console")
		CONS_Printf(player, "types: Standard, Notice, Warning, Error")
		return
	end
	if not message then
		message = typeof
		typeof = "s"
	end
	
	local subber = string.sub(string.lower(typeof), 1, 1)
	if subber == "n" then
		print("\x83".."NOTICE: \x80"..message)
	elseif subber == "w" then
		print("\x82".."WARNING: \x80"..message)
	elseif subber == "e" then
		print("\x85".."ERROR: \x80"..message)
	else
		print(message)
	end
end
COM_AddCommand('print', CMD_DoPrint, 1)

local function CMD_FreezeCommand(player, target)
	if (target == nil) then
        CONS_Printf(player, "freeze <node/all>: Freezes the player, wow!")
        return
    end

    if not (player.mo) then
		CONS_Printf(player, "You don't exist, so you won't freeze players for trolling.")
		return
	end

	local all 

    if (target == "all") then
    	for allplayers in players.iterate do
    		if not JoeBase.IsValid(allplayers.mo) then
    			CONS_Printf(player, "This can't be executed! (some players may be dead?)")
    			return
    		end

    		all = allplayers

    		if (allplayers.is_frozen) then
    			allplayers.is_frozen = false
    		else
    			allplayers.is_frozen = true
    		end
    	end

    	local message = (all.is_frozen) and "froze" or "unfroze"

	   	print(JoeBase.GetPlayerName(player, false, false) .. "\x80 " .. message .. " all players!")
    	return
    end

    target = tonumber(target)

    if (target > 32 or target < 0) then return end

     if players[target] == nil then 
    	CONS_Printf(player, "That player doesn't exist! Aborting...")
    	return
    end

	target = players[target]

	if JoeBase.IsValid(target.mo) then
		if (target.is_frozen) then
			target.is_frozen = false

			CONS_Printf(target, JoeBase.GetPlayerName(player, false, false) .. "\x80 unfroze you! Thank him for that!")
		else
			target.is_frozen = true

			CONS_Printf(target, JoeBase.GetPlayerName(player, false, false) .. "\x80 froze you! Darn...")
		end

	end
end
COM_AddCommand("freeze", CMD_FreezeCommand, COM_ADMIN)

-- GodMode, self-explanatory.
local function CMD_GodToggle(player)
	if not (gamestate == GS_LEVEL) then
		CONS_Printf(player, onlylevel)
		return
	end

	if (player.force_godmode == false) then
		player.force_godmode = true
	else
		player.force_godmode = false
	end

	local message = string.format("%s %s.", "God Mode", (player.force_godmode) and "enabled" or "disabled")
	CONS_Printf(player, message)
end
COM_AddCommand("god", CMD_GodToggle, 1)

-- Noclip, self-explanatory too.
local function CMD_NoclipToggle(player)
	if not (gamestate == GS_LEVEL) then
		CONS_Printf(player, onlylevel)
		return
	end

	if (player.force_noclip == false) then
		player.force_noclip = true
	else
		player.force_noclip = false
	end

	local message = string.format("%s %s.", "Noclipping Mode", (player.force_noclip) and "enabled" or "disabled")
	CONS_Printf(player, message)

end
COM_AddCommand("noclip", CMD_NoclipToggle, 1)

//
-- funtools.lua starts here, intended for all player usage.
//

-- shield, reworked since the old one sucked.
local shieldtypes = {
	{name = "\x80" .. "No",			   value = SH_NONE, 	   sound = sfx_addfil}, -- trolling
	{name = "\x8B" .. "Pity", 		   value = SH_PITY, 	   sound = sfx_shield},
	{name = 		  "Whirlwind", 	   value = SH_WHIRLWIND,   sound = sfx_wirlsg},
	{name = "\x85" .. "Armageddon",    value = SH_ARMAGEDDON,  sound = sfx_armasg},
	{name = "\x8E" .. "Pink", 		   value = SH_PINK, 	   sound = sfx_shield},
	{name = "\x87" .. "Elemental", 	   value = SH_ELEMENTAL,   sound = sfx_elemsg},
	{name = "\x83" .. "Attraction",    value = SH_ATTRACT,	   sound = sfx_attrsg},
	{name = "\x89" .. "Force", 		   value = SH_FORCE|1,	   sound = sfx_forcsg},
	{name = "\x87" .. "S3K Flame", 	   value = SH_FLAMEAURA,   sound = sfx_s3k3e},
	{name = "\x88" .. "S3K Bubble",    value = SH_BUBBLEWRAP,  sound = sfx_s3k3f},
	{name = "\x82" .. "S3K Lightning", value = SH_THUNDERCOIN, sound = sfx_s3k41}
}

COM_AddCommand('shield', function(player, arg1)
	if not (gamestate == GS_LEVEL) then
		CONS_Printf(player, onlylevel)
		return
	end
	
	if not arg1 then
		CONS_Printf(player, 
		"shield <shield>: Change your shield!",
		"Valid values:",
		"1: " .. shieldtypes[1].name .. " shield",
		"2: " .. shieldtypes[2].name .. " shield",
		"3: " .. shieldtypes[3].name .. " shield",
		"4: " .. shieldtypes[4].name .. " shield",
		"5: " .. shieldtypes[5].name .. " shield",
		"6: " .. shieldtypes[6].name .. " shield",
		"7: " .. shieldtypes[7].name .. " shield",
		"8: " .. shieldtypes[8].name .. " shield",
		"9: " .. shieldtypes[9].name .. " shield",
		"10: " .. shieldtypes[10].name .. " shield",
		"11: " .. shieldtypes[11].name .. " shield"
		)
		return
	end

	if (tonumber(arg1) == nil) then
		CONS_Printf(player, "\x82" .. arg1 .. "\x80 is not a valid option.")
		return
	end
	
	local shieldselected = tonumber(arg1)
	
	if (shieldselected < 1) or (shieldselected > 11) then
		CONS_Printf(player, "\x85" .. "ERROR: " .. "\x80" .. "Number out of range (1 - 11)")
		return
	end
	
	local shielddata = shieldtypes[shieldselected]

	P_SwitchShield(player, shielddata.value)
	S_StartSound(player.mo, shielddata.sound)
end)

-- super, self-explanatory. Can be made on you or other players.
COM_AddCommand("super", function(player, playerid)
	if not (gamestate == GS_LEVEL) then
		CONS_Printf(player, onlylevel)
		return
	end

	if (player.solchar) then
		CONS_Printf(player, "This command doesn't work for \x82" .. "solchars characters... \x80" .. "Sorry!")
		return
	end

	if not All7Emeralds(emeralds) then
		CONS_Printf(player, "You need all the".. "\x83 emeralds" .. "\x80 to do this!")
		S_StartSound(player.mo, sfx_s3k8c)
		return
	end

	// yeah
	local function P_ResetSuper(player)
		player.powers[pw_super] = 0 -- do not remove the super flag, you wont be super if you press spin after all
		player.powers[pw_flashing] = TICRATE
		
		P_SpawnShieldOrb(player)
		P_FlashPal(player, PAL_WHITE, 3)
		player.realmo.color = player.skincolor
		
		P_RestoreMusic(player)
		S_StartSound(player.realmo, sfx_s3k66)
	end
	
	if (playerid == "all") and ((server == player) or IsPlayerAdmin(player)) then
		for otherplayer in players.iterate do
			if not otherplayer.powers[pw_super] then
				otherplayer.charflags = $ | SF_SUPER
				otherplayer.rings = $ + 100
				P_DoSuperTransformation(otherplayer, true)
			else
				otherplayer.rings = $ - 50
				P_ResetSuper(otherplayer)
			end
		end
		return
	end
	
	playerid = tonumber(playerid)
	if (playerid == nil) then
		if not player.powers[pw_super] then
			player.charflags = $ | SF_SUPER
			player.rings = $ + 100
			P_DoSuperTransformation(player, false)
		else
			player.rings = $ - 50
			P_ResetSuper(player)
		end
	else
		if (players[playerid] == nil) then
			CONS_Printf(player, "\x85" .. "ERROR: " .. "\x80" .. "That player doesn't exist!")
			return
		end
		
		if not players[playerid].powers[pw_super] then
			players[playerid].charflags = $ | SF_SUPER
			players[playerid].rings = $ + 100
			P_DoSuperTransformation(players[playerid], false)
		else
			players[playerid].rings = $ - 50
			P_ResetSuper(players[playerid])
		end
	end
end)

-- suicide, a replacement that kills you with some extras.
COM_AddCommand('suicide', function(player)
	if not (gamestate == GS_LEVEL or gamestate == GS_INTERMISSION) then
		CONS_Printf(player, onlylevel)
		return
	end

	if player.mo then
		if (player.mo.eflags & MFE_UNDERWATER) then
			P_DamageMobj(player.mo, nil, nil, 1, DMG_DROWNED)
		else
			P_DamageMobj(player.mo, nil, nil, 1, DMG_INSTAKILL)
		end
	end
end)

-- Colorize, yeah, that too.
COM_AddCommand("colorize", function(player)
	if not (gamestate == GS_LEVEL) then
		CONS_Printf(player, onlylevel)
		return
	end

	if (player.force_colorize == false) then
		player.force_colorize = true
	else
		player.force_colorize = false
	end

	local message = string.format("You %s %s!", (player.force_colorize) and "are now" or "aren't", "colorized")
	CONS_Printf(player, message)
end)

-- rings, how many times im going to say "self-explanatory"?
COM_AddCommand("rings", function(player, arg1)
    if arg1 == nil then
        CONS_Printf(player, 'rings <value>: Set your rings!')
        return
    end

    arg1 = tonumber(arg1)

    if JoeBase.IsValid(player.mo) then
        player.rings = 0
        P_GivePlayerRings(player, arg1)
    end
end)

-- lives, ...
COM_AddCommand("lives", function(player, arg1)
    if arg1 == nil then
        CONS_Printf(player, 'lives <value>: Set your lives!')
        return
    end

    arg1 = tonumber(arg1)

    if JoeBase.IsValid(player.mo) then
        player.lives = 0
        P_GivePlayerLives(player, arg1)
    end
end)

-- scale, for all players
COM_AddCommand("scale", function(player, scale)
	local nScale = FloatNumber(scale)
	
	if scale == nil then
		CONS_Printf(player, "scale <value>: Change your scale by setting a number!")
		return
	end
	
	if (tonumber(nScale)) and (nScale > 0) then
		player.mo.destscale = nScale
	end
end)

-- shoes, no longer admin only.
COM_AddCommand("shoes", function(player, time)
	if not time then
		CONS_Printf(player, "shoes <time>: Give yourself Super Sneakers")
		return
	end

	local N = tonumber(time)
	if N ~= nil then
		player.powers[pw_sneakers] = N*TICRATE
		S_StartSound(player.mo, sfx_3db06)
	end
end)

-- invuln, oh my god i hate saying "self-explanatory" too many times
COM_AddCommand("invuln", function(player, time)
	if not time then
		CONS_Printf(player, "invuln <time>: give yourself invulnerability")
		return
	end

	local N = tonumber(time)
	if N ~= nil then
		player.powers[pw_invulnerability] = N*TICRATE
		S_StartSound(player.mo, sfx_3db06)
	end
end)