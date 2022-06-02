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

local CL_TeamChange = function(player, teams, is_spec, autobalance, scramble)
	-- when you have to redo every logic
	if G_GametypeHasTeams() then
		player.spectator = not (is_spec or teams)
	
		player.ctfteam = teams
		player.playerstate = PST_REBORN
	
	else
		player.spectator = not is_spec
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

	elseif (not team and is_spec) then
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

local C_FinalMessageResult = function(player, type, target, message)
	local player_name;

	-- The unique message.
	if (type == 0) then
		player_name = JoeBase.GetPlayerName(player, true, true)
		
		-- if we are on dedicated server, and the server sends a message...
		if (player == server) and not player.realmo then
			chatprint("\x82SERVER" .. "\x80: " .. message)
			S_StartSound(nil, sfx_thok, nil)
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
		
		local player_msg = "\x82" .. "To " .. target_name .. "\x80: " .. message
		local target_msg = "\x82" .. "From " .. player_name .. "\x80: " .. message
		chatprintf(player, player_msg)
		S_StartSound(nil, chatsound_private, player)

		chatprintf(target, target_msg)
		S_StartSound(nil, chatsound_private, target)

	-- ... CSay?
	elseif (type == 3)
	
	end
	
	return true
end
addHook("PlayerMsg", C_FinalMessageResult)