//
-- some miscellaneous stuff that doesnt fit in a regular script
-- Jaden By
//

//
// Custom Rankings !!!!!!
//

local DrawAllRankings = function(v)
	if not (multiplayer or netgame) then return end

	local coop_table = {}
	local match_table = {}
	
	-- get players on the server, coop edition
	for player in players.iterate do 
		table.insert(coop_table, player) 
	end

	-- get players, match edition
	for player in players.iterate do 
		if player.spectator then continue end
		
		table.insert(match_table, player)
	end
	
	//
	// draw it!
	//
	-- coop
	if (gametyperules & GTR_FRIENDLY) or (gametyperules & GTR_RACE) then
		hud.disable("rankings")
		hud.disable("coopemeralds")
		hud.disable("tokens")

		M_DrawCoopOverlay(v, coop_table)
	
	-- noncoop
	elseif (gametyperules & GTR_RINGSLINGER) then
		hud.disable("rankings")
		hud.disable("teamscores")

		M_DrawMatchOverlay(v, match_table)

	-- not related to above
	else
		if not hud.enabled("rankings") then
			hud.enable("rankings")
		end
	end
end
addHook("HUD", DrawAllRankings, "scores")
