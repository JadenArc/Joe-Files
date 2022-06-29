//
-- some miscellaneous stuff that doesnt fit in a regular script
-- Jaden By
//

//
// Boss health bar
//

local boss = nil
local boss_ticker = 0

local boss_maxdist = 4096 * FRACUNIT

local boss_names = {
	// Vanilla Bosses...
	[MT_EGGMOBILE] = "Egg Mobile",
	[MT_EGGMOBILE2] = "Egg Slimer",
	[MT_EGGMOBILE3] = "Sea Egg",
	[MT_EGGMOBILE4] = "Egg Colosseum",
	
	[MT_FANG] = "Fang",
	[MT_METALSONIC_BATTLE] = "Metal Sonic",
	
	[MT_CYBRAKDEMON] = "Black Eggman",
	[MT_BLACKEGGMAN] = "Brak Eggman"
}

// get the boss object (just one, for consistency.)
addHook("BossThinker", function(mo) boss = mo end)

// animations, basic thing since drawFill ignores translucency.
addHook("MapLoad", do boss_ticker = 0 end)

local HU_DrawBossBar = function(v, player)
	local x, y = 160, 187
	local flags = V_SNAPTOBOTTOM
	
	local bar_width, bar_height = 68, 10

	// dont draw this if our boss doesnt exist!
	if not JoeBase.IsValid(boss) then return end

	local bar_color = ((boss.flags2 & MF2_FRET) and (leveltime % 2)) and 1 or 36
	
	//
	-- Timing with animations
	//

	// if some boss is alive, increase the timer!
	if (boss.health and (leveltime >= 15)) then
		boss_ticker = min($ + 1, 64)
		
	// do some fade out if the boss is completely dead.
	elseif (boss.health <= 0) then
		boss_ticker = max(0, $ - 1)
	end

	-- lolxd
	local animate_things = JoeBase.GetEasingTics(boss_ticker)
	local boss_anims = ease.inoutback(animate_things, 320, y)

	//
	-- Drawing logic
	//

	// dont draw it if its dead!
	if (boss.flags2 & MF2_BOSSDEAD) and (boss.health == nil) then return end

	if not (R_PointToDist2(player.mo.x, player.mo.y, boss.x, boss.y) < boss_maxdist) then return end

	-- fancy bar
	local bar_health = FixedInt(FixedDiv(boss.health * FRACUNIT, boss.info.spawnhealth * FRACUNIT) * bar_width)
				
	v.drawFill(x - (bar_width / 2), boss_anims - 2, bar_width, bar_height, 31|flags) -- Big black bar
	v.drawFill(x + 2 - (bar_width / 2), boss_anims, bar_width - 4, bar_height - 4, 47|flags) -- dark bar

	v.drawFill(x + 2 - (bar_width / 2), boss_anims, bar_health - 4, bar_height - 4, bar_color|flags) -- light bar that represents health

	-- name, current health and total health,
	local boss_name = boss_names[boss.type] or "Boss"
	local boss_string = boss.health .. " / " .. boss.info.spawnhealth

	v.drawString(x, boss_anims - 10, boss_name, V_YELLOWMAP|V_ALLOWLOWERCASE|flags, "thin-center")
	v.drawString(x, boss_anims, boss_string, V_40TRANS|flags, "thin-center")
end
addHook("HUD", HU_DrawBossBar, "game")

//
// Custom Rankings !!!!!!
//

local HU_DrawAllRankings = function(v)
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
addHook("HUD", HU_DrawAllRankings, "scores")
