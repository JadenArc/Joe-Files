//
-- Custom Emblems on Multiplayer
-- By Jaden

-- This will be removed (or modified) until !1756 gets merged (and of course, the game updates).
//

local old_emblem = mobjinfo[MT_EMBLEM]

// the				somewhat close emerald skincolors
local Emblem_Colors = {
	SKINCOLOR_MINT, -- 1st emerald,
	SKINCOLOR_BUBBLEGUM, -- 2nd emerald,
	SKINCOLOR_SAPPHIRE, -- and it goes on...
	SKINCOLOR_SKY,
	SKINCOLOR_ORANGE,
	SKINCOLOR_SALMON,
	SKINCOLOR_AETHER,
	SKINCOLOR_JET -- until the 8th emerald, which represents the 8th special stage.
}

freeslot("S_COOPEMBLEM", "MT_COOPEMBLEM") -- freeslot those!

states[S_COOPEMBLEM] = {SPR_EMBM, H | FF_PAPERSPRITE, -1, nil, 0, 0, S_NULL}
mobjinfo[MT_COOPEMBLEM] = {
	doomednum = -1,
	spawnstate = S_COOPEMBLEM,
	deathstate = S_SPRK1,
	deathsound = old_emblem.deathsound,
	radius = old_emblem.radius,
	height = old_emblem.height,
	flags = old_emblem.flags
}

// yeah
local EmblemSpawn = function()
	-- reset the variabl
	JoeBase.MP_EmblemsTotal = 0
	JoeBase.MP_EmblemsGot = 0

	for mt in mapthings.iterate do
		if (mt.type == old_emblem.doomednum) then
			-- yeah
			local align = (mt.options & MTF_AMBUSH) and (24*FRACUNIT) or 0

			JoeBase.MP_EmblemsTotal = $ + 1

			-- spawning logic
			local x = mt.x*FRACUNIT
			local y = mt.y*FRACUNIT

			local emblem = P_SpawnMobj(x, y, 0, MT_COOPEMBLEM)

			emblem.z = emblem.floorz + mt.z*FRACUNIT + align

			emblem.color = Emblem_Colors[P_RandomRange(1, #Emblem_Colors)]
		end
	end
end
addHook("MapLoad", EmblemSpawn)

// Think emblem, THINK!
local EmblemThink = function(mo)
	if not JoeBase.IsValid(mo) then return end
	
	mo.shadowscale = (2*FRACUNIT)/3

	mo.angle = $ + FixedAngle(2*FRACUNIT)
	
	// if the emblem hasnt been touched, spawn sum sparkles
	if mo.health then
		local x, y, z = P_RandomRange(30, -30)*FRACUNIT, P_RandomRange(30, -30)*FRACUNIT, P_RandomRange(30, -30)*FRACUNIT

		if (P_RandomRange(0, 3) == 2) then
			local sparkle = P_SpawnMobjFromMobj(mo, x, y, z + 14*FRACUNIT, MT_BOXSPARKLE)
			sparkle.colorized = true
			sparkle.color = mo.color

			sparkle.tics = 5
			sparkle.frame = $ | (FF_FULLBRIGHT|FF_ADD)
		end
	
	// otherwise, dont spawn the sparkles and do sum nice fade
	else
		mo.frame = $ | FF_TRANS50
	end
end
addHook("MobjThinker", EmblemThink, MT_COOPEMBLEM)

// What happens if you touch a emblem?
local EmblemTouch = function(emblem, toucher)
	if not (JoeBase.IsValid(emblem) and emblem.health) then return end
	
	if JoeBase.IsValid(toucher.player) then
		if (JoeBase.MP_EmblemsGot >= JoeBase.MP_EmblemsTotal) then
			P_AddPlayerScore(toucher.player, 50000)
			S_StartSound(toucher, sfx_s1bf)
		else
			P_AddPlayerScore(toucher.player, 5000)
		end
		
		S_StartSound(toucher, emblem.info.deathsound) -- yeah!
		
		emblem.health = 0

		JoeBase.MP_EmblemsGot = $ + 1

		return true
	end
end
addHook("TouchSpecial", EmblemTouch, MT_COOPEMBLEM)