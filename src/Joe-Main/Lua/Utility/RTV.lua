--Based on the work of Wolfs, Lat'

local function R_ClearRTV()
	for player in players.iterate do
		player.RTV = false
	end
end

local function R_DoRTV(source)
	if (server.RTV_cooldown) then
		chatprintf(source, "\x84* RTV is on cooldown. Please wait \x82" .. server.RTV_cooldown / TICRATE .. " seconds \x84to continue.", true)
		return false
	end
		
	source.RTV = true
	local playercount, rtvamount = 0, 0
	
	for player in players.iterate do
		playercount = $ + 1
	
		if player.RTV then
			rtvamount = $ + 1
		end
	end
		
	local rtvneeded = (playercount/2) + 1
		
	if (rtvamount < rtvneeded) then
		chatprint("\x83* " .. source.name .. " wants to skip this map. (\x82" .. rtvamount .. "\x83 votes, \x82" .. rtvneeded.. "\x83 needed)", true)
	else
		chatprint("\x83* Vote requirement reached. Exiting the level...", true)
		R_ClearRTV()
		bluescore, redscore = 0, 0
		
		-- Remove everyone's score.
		for player in players.iterate do player.score = 0 end
		G_ExitLevel()
			
		server.RTV_cooldown = 60*TICRATE
	end
end

local R_MsgRTV = function(source, msgtype, target, msg)
	if not (netgame) then return end
	
	if (msgtype ~= 0) then return false end
	if (server.RTV_intermission == 1) then return false end
	
	if (msg:sub(1, 3):lower() == "rtv") then
		R_DoRTV(source)

		return true
	end
end

local R_CmdRTV = function(player)
	if not (netgame) then return end

	if (server.RTV_intermission == 1) then return end

	R_DoRTV(player)
end

addHook("PlayerMsg", R_MsgRTV)
COM_AddCommand("rtv", R_CmdRTV)

addHook("ThinkFrame", function()
	if not (server) return end
	
	if (server.RTV_cooldown ~= nil) and (server.RTV_cooldown > 0) then
		server.RTV_cooldown = $ - 1
	end
end)

addHook("MapChange", do
	R_ClearRTV() -- Don't preserve RTV between maps
	server.RTV_intermission = 0 -- Intermission has ended
end)

addHook("IntermissionThinker", do
	server.RTV_intermission = 1 
end)