//
-- Custom Chat and else
-- By Jaden

-- This only changes that chat display.
//

// - C_ prefix means chat
// - CL_ prefix means chat logic

local chatsound_fail = sfx_s258
local chatsound_event = sfx_s25a
local chatsound_teams = sfx_ding
local chatsound_private = sfx_s3k92
local chatsound_unmuted = sfx_ideya

//
// Mute and unmuting commands
//

local CL_MuteThink = do
	for player in players.iterate do
		-- could leave this as a int, but i dont want sum temp-mutes.......
		player.muted = $ or false

		-- reasons, people can forget about it
		player.muted_reason = $ or ""
	end
end
addHook("PreThinkFrame", CL_MuteThink)

local CMD_MutePlayer = function(player, target, reason)
	if (target == nil) then
		CONS_Printf(player, "\x82muteplayer <target> [reason]\x80: Mutes a player, self-explanatory.")
		return
	end

	target = tonumber($)
	reason = $ or "No Reason."

	local target_player = players[target]

	if not (target_player) then
		CONS_Printf(player, "That player doesn't exist!")
		return
	end

	if JoeBase.IsServerOrAdmin(target_player) then
		CONS_Printf(player, "You can't mute admins or hosts! They are so powerful for this command...")
		return
	end

	if (target_player.muted) then
		CONS_Printf(player, "That player is already muted! Don't troll him like this...")
		return
	end

	target_player.muted = true
	target_player.muted_reason = reason

	local message = string.format("%s\x80 muted %s\x80. \x82(%s)", JoeBase.GetPlayerName(player, false, false), JoeBase.GetPlayerName(target_player, false, false), target_player.muted_reason)

	chatprint(message)
	S_StartSound(nil, chatsound_event)
end
COM_AddCommand("muteplayer", CMD_MutePlayer, COM_ADMIN)

-- the same thing, but backwards
local CMD_UnmutePlayer = function(player, target)
	if (target == nil) then
		CONS_Printf(player, "\x82unmuteplayer <target>\x80: Unmutes a player, it's also self-explanatory too.")
		return
	end

	target = tonumber($)

	local target_player = players[target]

	if not (target_player) then
		CONS_Printf(player, "That player doesn't exist!")
		return
	end

	if not (target_player.muted) then
		CONS_Printf(player, "That player is not muted! Don't be silly!")
		return
	end

	target_player.muted = false

	local message = string.format("%s\x80 unmuted %s\x80!", JoeBase.GetPlayerName(player, false, false), JoeBase.GetPlayerName(target_player, false, false))

	chatprint(message)
	S_StartSound(nil, chatsound_unmuted)
end
COM_AddCommand("unmuteplayer", CMD_UnmutePlayer, COM_ADMIN)

//
// hurt messages, team info...
//

local CL_TeamChange = function(player, teams, from_spec, autobalance, scramble)
	-- when you have to redo every logic
	if G_GametypeHasTeams() then
		player.spectator = not (from_spec or teams)
	
		player.ctfteam = teams
		player.playerstate = PST_REBORN
	
	else
		player.spectator = not from_spec
		player.playerstate = PST_REBORN
	end

	local reason = ""

	local team_str = (player.ctfteam == 1) and "\x85" .. "Red Team" or "\x84" .. "Blue Team"
	local player_name = JoeBase.GetPlayerName(player, true, false)

	--
	-- message funky!
	--

	// autobalance.
	if (autobalance) then
		reason = string.format("%s\x82 was autobalanced to the %s\x80.", player_name, team_str)

	// team scramble.
	elseif (scramble) then
		reason = string.format("%s\x82 was scrambled to the %s\x80.", player_name, team_str)

	// IT, Red or Blue Team.
	elseif (player.ctfteam == 1) or (player.ctfteam == 2) then
		reason = string.format("%s\x82 switched to the %s\x80.", player_name, team_str)

	elseif (not team and from_spec) then
		reason = string.format("%s\x82 entered the game\x80.", player_name)

	// spectator.
	elseif (player.spectator) then
		reason = string.format("%s\x82 became a spectator\x80.", player_name)
	end

	chatprint("\x82* " .. reason)
	S_StartSound(nil, chatsound_event, nil)

	return false
end
addHook("TeamSwitch", CL_TeamChange)

//
// Actual Chat logic
//

local C_FinalMessageResult = function(player, type, target, message)
	local player_name;

	-- Yeah, don't even try.
	if (player.muted) then
		chatprintf(player, "\x82* You are muted! (Reason: \x80" .. player.muted_reason .. "\x82)")
		S_StartSound(nil, chatsound_fail, player)
		return true
	end

	-- The unique message.
	if (type == 0) then
		player_name = JoeBase.GetPlayerName(player, true, true)
		
		-- if we are on dedicated server, and the server sends a message...
		if (player == server) and not player.realmo then
			chatprint("<\x82SERVER" .. "\x80> " .. message)
			S_StartSound(nil, sfx_s1a1, nil)
			return true
		end
		
		chatprint(player_name .. "\x80: " .. message, true)
	
	-- Team Messages.
	elseif (type == 1) then
		player_name = JoeBase.GetPlayerName(player, true, false)
		
		-- self-explanatory.
		if not (gamestate == GS_LEVEL) then
			chatprintf(player, "\x82" .. "* Message failed, we ain't on a level, dumbo.")
			S_StartSound(nil, chatsound_fail, player)
			return true
		end

		-- dont be a troll...
		if (player.ctfteam == 0) then
			chatprintf(player, "\x82" .. "* Message failed, spectators ain't on teams!")
			S_StartSound(nil, chatsound_fail, player)
			return true
		end
		
		for team_players in players.iterate do
			if (player.ctfteam == team_players.ctfteam) then
				chatprintf(team_players, "[Team] " .. player_name .. "\x80: " .. message)
				S_StartSound(nil, chatsound_teams, player)
			end
		end
	
	-- Private Messages, or PM for short.
	elseif (type == 2) then
		local target_name = JoeBase.GetPlayerName(target, false, false)
		player_name = JoeBase.GetPlayerName(player, false, false)
		
		-- So alone, that you mind talking with yourself.
		if (player == target) then
			chatprintf(player, "\x82* Message failed, the target is yourself.")
			S_StartSound(nil, chatsound_fail, player)
			return true
		end

		-- You cant talk to muted players!
		if (target.muted) then
			chatprintf(player, "\x82* That player is muted, sorry!")
			S_StartSound(nil, chatsound_fail, player)
			return true
		end
		
		local player_msg = "\x82[To " .. target_name .. "\x82]\x80: " .. message
		local target_msg = "\x82[From " .. player_name .. "\x82]\x80: " .. message
		
		chatprintf(player, player_msg)
		S_StartSound(nil, chatsound_private, player)

		chatprintf(target, target_msg)
		S_StartSound(nil, chatsound_private, target)
	
	-- csay...?
	elseif (type == 3) then
		-- i can do sum custom csay function, but hud functions cant do anything here...
		return false
	end
	
	return true
end
addHook("PlayerMsg", C_FinalMessageResult)