//
-- some miscellaneous stuff that doesnt fit in a regular script
-- Jaden By
//

//
// Boss health bar
//

local boss_ticker = 0

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

// animations, basic thing since drawFill ignores translucency.
addHook("MapLoad", do boss_ticker = 0 end)

addHook("HUD", function(v, player, ticker, endticker)
	-- where it starts to fade in
	if (ticker >= 75) then
		boss_ticker = $ + 1
	end
end, "titlecard")

local HL_GetBossInfo = function(player)
	local boss_health, total_health = 0, 0

	local boss_maxdist = 3064*FRACUNIT
	local boss_inpain = false
	local boss_name = "Boss"

	// Instead of looking for a boss in a map, do searchBlockmap.
	// With that, we can find ALL the bosses in a map instead of just one.
	local mo = player.realmo

	local x1, x2 = mo.x - boss_maxdist, mo.x + boss_maxdist 
	local y1, y2 = mo.y - boss_maxdist, mo.y + boss_maxdist

	searchBlockmap("objects", function(boss_prev, boss)
		if (boss.flags & MF_BOSS) and not (boss.flags2 & MF2_BOSSDEAD) and (boss.health ~= nil) then				
			boss_health = $ + boss.health
			total_health = $ + boss.info.spawnhealth

			if (boss.flags2 & MF2_FRET) then boss_inpain = true end

			if boss_names[boss.type] then
				boss_name = boss_names[boss.type]
			end
		end

	end, mo, x1, x2, y1, y2)

	return boss_health, total_health, boss_inpain, boss_name
end

local HU_DrawBossBar = function(v, player)
	local x, y = 160, 187
	local flags = V_SNAPTOBOTTOM
	
	local animate_things = JoeBase.GetEasingTics(boss_ticker)
	local boss_anims = ease.outback(animate_things, 320, y)

	local boss_health, total_health, boss_inpain, boss_name = HL_GetBossInfo(player)
	
	local bar_width, bar_height = 94, 10
	local bar_color = (boss_inpain and (leveltime % 2)) and 1 or 36

	// dont draw this if we dont have any health! (or else, divide by zero, and thats illegal)
	if not (boss_health) then return end

	-- fancy bar
	local bar_health = FixedInt(FixedDiv(boss_health * FRACUNIT, total_health * FRACUNIT) * bar_width)
			
	v.drawFill(x - (bar_width / 2), boss_anims - 2, bar_width, bar_height, 31|flags)
	v.drawFill(x + 2 - (bar_width / 2), boss_anims, bar_health - 4, bar_height - 4, bar_color|flags)

	-- name, current health and total health,
	local boss_string = boss_health .. " / " .. total_health

	v.drawString(x, boss_anims - 11, boss_name, V_YELLOWMAP|V_ALLOWLOWERCASE|flags, "center")
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
