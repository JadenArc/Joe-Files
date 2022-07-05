-- admintools.lua and funtools.lua being merged with a rewrite or recreation

-- This is basically on every command.
local G_IsNotOnLevel = function(player)
	if (gamestate ~= GS_LEVEL) then
		CONS_Printf(player, "This can only be used on a \x82level\x80.")
		return true
	end

	return false
end

-- yeah
local P_ResetSuper = function(player)
	player.powers[pw_super] = 0 -- do not remove the super flag, you wont be super if you press spin after all
	player.powers[pw_flashing] = TICRATE

	P_SpawnShieldOrb(player) -- if you had a shield, restore it!

	P_FlashPal(player, PAL_WHITE, 5)
	player.realmo.color = player.skincolor

	P_RestoreMusic(player)
	S_StartSound(player.realmo, sfx_s3k66)
end

//
-- Let's start with the admin-only commands.
//

-- emeralds, lol...
CV_RegisterVar({
	name = "emeralds",
	defaultvalue = "No",
	flags = CV_NETVAR | CV_CALL | CV_NOINIT,
	possiblevalue = CV_YesNo,
	func = function(var)
		local emflags = 127 -- result of all emerald flags

		if var.value == 1 then
			emeralds = $ | (emflags)
			S_StartSound(nil, sfx_cgot)
			print("The emeralds were \x8Bspawned! \x80Now you can be super.")

		elseif var.value == 0 then
			emeralds = $ & ~(emflags)
			S_StartSound(nil, sfx_lose)
			print("The emeralds suddenly \x85vanished! \x80Some wacky admin did it...")
		end
	end
})

-- Kill command, admins can kill players if they want to.
local function CMD_KillCommand(player, target)
	if G_IsNotOnLevel(player) then return end

    if target == nil then
        CONS_Printf(player, "\x82kill <node>\x80: Kills the node. (Use 'nodes' on the console to see which nodes are which.)")
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
        CONS_Printf(player, '\x82' .. 'dofor <node/all/server> <command>\x80: Inserts a command on the selected node.')
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
	if G_IsNotOnLevel(player) then return end

    if target == nil then
        CONS_Printf(player, "\x82goto <node>\x80: Goes to the given player's coordinates")
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
	if G_IsNotOnLevel(player) then return end

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
        CONS_Printf(player, '\x82' .. 'changemus <musicid>\x80: Changes music for everyone.')
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
	if G_IsNotOnLevel(player) then return end

	local nScale = J_DoFloatNumber(scale)

    if target == nil then
        CONS_Printf(p, "\x82scale <target> <value>\x80: Make someone bigger or smaller!")
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
	if G_IsNotOnLevel(player) then return end

    if (object == nil) then
        CONS_Printf(player, "\x82spawnobject <object>\x80: Spawns object via MT_*\n" ..
							"Go to https://wiki.srb2.org/wiki/List_of_Object_types to get a list of Object Types."
		)
        return
    end

    object = _G[string.upper(object)]

	if (object == nil) then
		CONS_Printf(player, "That object doesn't exist! \x82(mistyping?)")
		return
	end

    if JoeBase.IsValid(player.mo) then
		local result = P_SpawnMobjFromMobj(player.mo, 0, 0, 8*FRACUNIT, object)

 		result.angle = player.mo.angle
		P_SetScale(result, player.mo.scale)
    end
end
COM_AddCommand('spawnobject', CMD_SpawnobjectCommand, 1)

-- killallenemies, you know the rules.
local function CMD_KillEnemiesCommand(player)
	if G_IsNotOnLevel(player) then return end

    for object in mobjs.iterate("mobj") do
        if (object.flags & (MF_ENEMY|MF_BOSS)) then
            P_KillMobj(object, nil, player.mo)
        end
    end
end
COM_AddCommand('killallenemies', CMD_KillEnemiesCommand, 1)

-- print, and so do i.
local function CMD_DoPrint(player, typeof, message)
	if not typeof then
		CONS_Printf(player, "\x82print [type] <message>\x80: print something to the console")
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
	if G_IsNotOnLevel(player) then return end

	if (target == nil) then
        CONS_Printf(player, "\x82" .. "freeze <node/all>\x80: Freezes the player, wow!")
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
	if G_IsNotOnLevel(player) then return end

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
	if G_IsNotOnLevel(player) then return end

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
local shieldList = {
	[0] = {value = SH_NONE, 	    sound = sfx_none}, 	 -- None
	[1] = {value = SH_PITY, 	    sound = sfx_shield}, -- Pity
	[2] = {value = SH_WHIRLWIND,    sound = sfx_wirlsg}, -- Whirlwind
	[3] = {value = SH_ARMAGEDDON,   sound = sfx_armasg}, -- Armageddon
	[4] = {value = SH_PINK, 	    sound = sfx_shield}, -- Pink Pity
	[5] = {value = SH_ELEMENTAL,    sound = sfx_elemsg}, -- Elemental
	[6] = {value = SH_ATTRACT,		sound = sfx_attrsg}, -- Attract
	[7] = {value = SH_FORCE|1,		sound = sfx_forcsg}, -- Force
	[8] = {value = SH_FLAMEAURA,    sound = sfx_s3k3e},  -- Flame
	[9] = {value = SH_BUBBLEWRAP,   sound = sfx_s3k3f},  -- Bubble
	[10] = {value = SH_THUNDERCOIN, sound = sfx_s3k41}   -- Thunder
}

local function CMD_ShieldCommand(player, arg1)
	if G_IsNotOnLevel(player) then return end

	if not arg1 then
		CONS_Printf(player, "\x82shield <number>\x80: Change your shield! Valid values are from 1 to 11.")
		return
	end

	if (tonumber(arg1) == nil) then
		CONS_Printf(player, "\x82" .. arg1 .. "\x80 is not a valid option.")
		return
	end

	local shieldselected = tonumber(arg1)

	if (shieldselected < 0) or (shieldselected > 10) then
		CONS_Printf(player, "\x85" .. "ERROR: " .. "\x80Number out of range (0 - 10)")
		return
	end

	local shieldData = shieldList[shieldselected]

	P_SwitchShield(player, shieldData.value)
	S_StartSound(player.mo, shieldData.sound)
end
COM_AddCommand('shield', CMD_ShieldCommand)

-- super, self-explanatory. Can be used on you, or the other players.
local function CMD_SuperToggle(player, playerid)
	if G_IsNotOnLevel(player) then return end

	if not All7Emeralds(emeralds) then
		CONS_Printf(player, "You need all the".. "\x83 emeralds" .. "\x80 to do this!")
		S_StartSound(player.mo, sfx_s3k8c)
		return
	end

	if (playerid == "all") and JoeBase.IsServerOrAdmin(player) then
		for otherplayer in players.iterate do
			if not otherplayer.powers[pw_super] then
				otherplayer.charflags = $ | SF_SUPER
				otherplayer.rings = $ + 100
				P_DoSuperTransformation(otherplayer, false)
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
		return
	end

	-- selecting players is only for admins!
	if not JoeBase.IsServerOrAdmin(player) then
		CONS_Printf("Only admins can use this feature.")
		return
	end

	local player_selected = players[playerid]

	if (player_selected == nil) then
		CONS_Printf(player, "\x85" .. "ERROR: " .. "\x80That player doesn't exist!")
		return
	end

	if not player_selected.powers[pw_super] then
		player_selected.charflags = $ | SF_SUPER
		player_selected.rings = $ + 100
		P_DoSuperTransformation(player_selected, false)
	else
		player_selected.rings = $ - 50
		P_ResetSuper(player_selected)
	end
end
COM_AddCommand("super", CMD_SuperToggle)

-- suicide, a replacement that kills you with some extras.
local function CMD_SuicideCommand(player)
	if G_IsNotOnLevel(player) then return end

	if JoeBase.IsValid(player.mo) then
		if (player.mo.eflags & MFE_UNDERWATER) then
			P_DamageMobj(player.mo, nil, nil, 1, DMG_DROWNED)
		else
			P_DamageMobj(player.mo, nil, nil, 1, DMG_INSTAKILL)
		end
	end
end
COM_AddCommand('suicide', CMD_SuicideCommand)

-- Colorize, yeah, that too.
local function CMD_ColorizeToggle(player)
	if G_IsNotOnLevel(player) then return end

	if (player.force_colorize == false) then
		player.force_colorize = true
	else
		player.force_colorize = false
	end

	local message = string.format("You are now %s", (player.force_colorize) and "colorized!" or "un-colorized...")
	CONS_Printf(player, message)
end
COM_AddCommand("colorize", CMD_ColorizeToggle)

-- rings, how many times im going to say "self-explanatory"?
local function CMD_RingsCommand(player, arg1)
	if G_IsNotOnLevel(player) then return end

    if arg1 == nil then
        CONS_Printf(player, '\x82rings <value>\x80: Set your rings!')
        return
    end

    arg1 = tonumber(arg1)

    if JoeBase.IsValid(player.mo) then
        player.rings = 0
        P_GivePlayerRings(player, arg1)
    end
end
COM_AddCommand("rings", CMD_RingsCommand)

-- lives, ...
local function CMD_LivesCommand(player, arg1)
	if G_IsNotOnLevel(player) then return end

    if arg1 == nil then
        CONS_Printf(player, '\x82lives <value>\x80: Set your lives!')
        return
    end

    arg1 = tonumber(arg1)

    if JoeBase.IsValid(player.mo) then
        player.lives = 0
        P_GivePlayerLives(player, arg1)
    end
end
COM_AddCommand("lives", CMD_LivesCommand)

-- scale, for all players
local function CMD_ScaleCommand(player, scale)
	if G_IsNotOnLevel(player) then return end

	local nScale = J_DoFloatNumber(scale)

	if scale == nil then
		CONS_Printf(player, "\x82scale <value>\x80: Change your scale by setting a number!")
		return
	end

	if (tonumber(nScale)) and (nScale > 0) then
		player.mo.destscale = nScale
	end
end
COM_AddCommand("scale", CMD_ScaleCommand)

-- shoes, no longer admin only.
local function CMD_ShoesCommand(player, time)
	if G_IsNotOnLevel(player) then return end

	if not time then
		CONS_Printf(player, "\x82shoes <time>\x80: Give yourself Super Sneakers")
		return
	end

	time = tonumber($)
	if (time ~= nil) then
		player.powers[pw_sneakers] = time * TICRATE
		S_StartSound(player.mo, sfx_3db06)
	end
end
COM_AddCommand("shoes", CMD_ShoesCommand)

-- invuln, oh my god i hate saying "self-explanatory" too many times
local function CMD_InvulnCommand(player, time)
	if G_IsNotOnLevel(player) then return end

	if not time then
		CONS_Printf(player, "\x82invuln <time>\x80: give yourself invulnerability")
		return
	end

	time = tonumber($)
	if (time ~= nil) then
		player.powers[pw_invulnerability] = time * TICRATE
		S_StartSound(player.mo, sfx_3db06)
	end
end
COM_AddCommand("invuln", CMD_InvulnCommand)