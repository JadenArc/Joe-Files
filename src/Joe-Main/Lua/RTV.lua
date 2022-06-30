--Based on the work of Wolfs, Lat'

local function R_ClearRTV()
	for player in players.iterate do
		player.RTV = false
	end
end

//
// Toggling
//

local function R_DoRTV(source)
	if (server.RTV_cooldown) then
		chatprintf(source, "\x82* RTV is on cooldown. Please wait \x80" .. server.RTV_cooldown / TICRATE .. " seconds \x82to continue.", true)
		return true
	end

	if (source.RTV) then
		chatprintf(source, "\x82* You already cast either a RTV call, or a vote for it!")
		return true
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
		chatprint("\x82* " .. source.name .. " wants to skip this map. (\x80" .. rtvamount .. "\x83 votes, \x80" .. rtvneeded.. "\x86 needed)", true)
	
		server.RTV_active = true
	else
		chatprint("\x82* Vote requirement reached. Exiting the level...", true)
		R_ClearRTV()
		bluescore, redscore = 0, 0
		
		-- Remove everyone's score.
		for player in players.iterate do player.score = 0 end
		G_ExitLevel()
			
		server.RTV_active = false
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
addHook("PlayerMsg", R_MsgRTV)

local R_CmdRTV = function(player)
	if not (netgame) then return end

	if (server.RTV_intermission == 1) then return end

	R_DoRTV(player)
end
COM_AddCommand("rtv", R_CmdRTV)

//
// HUD
//

local R_RTVHud = function(v, ...)
	if not (server.RTV_active) then return end
	
	local playercount, rtvamount = 0, 0
	
	for player in players.iterate do
		playercount = $ + 1
	
		if player.RTV then
			rtvamount = $ + 1
		end
	end
	
	local rtvneeded = (playercount/2) + 1

	local x, y = 257, 180

	local bw = 78
	local bh = 20
	v.drawFill(x - (bw/2), y - (bh/3), bw, bh, 27)
	
	v.drawString(x, y, "Vote for:\x82 exitlevel", V_ALLOWLOWERCASE, "small-center")
	
	local votes = string.format("\x83%d \x80| \x86%d", rtvamount, rtvneeded)
	v.drawString(x, y + 5, votes, 0, "small-center")
end
addHook("HUD", R_RTVHud, "game")

//
// Functions
//

addHook("ThinkFrame", function()
	if not (server) return end
	
	if (server.RTV_cooldown ~= nil) and (server.RTV_cooldown > 0) then
		server.RTV_cooldown = $ - 1
	end
end)

addHook("MapChange", do
	R_ClearRTV() -- Don't preserve RTV between maps
	server.RTV_intermission = 0 -- Intermission has ended
	server.RTV_active = false
end)

addHook("IntermissionThinker", do
	server.RTV_intermission = 1 
end)