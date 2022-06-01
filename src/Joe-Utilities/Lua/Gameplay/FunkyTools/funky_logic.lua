//
// Yeah
// by Yeah
//

-- from terminal.
local function J_DoFloatNumber(src)
	if src == nil then return nil end
	
	if not src:find("^-?%d+%.%d+$") then -- not a valid number
		if tonumber(src) then
			return tonumber(src)*FRACUNIT
		else
			return nil
		end
	end

	local decPlace = src:find("%.")
	local whole = tonumber(src:sub(1, decPlace-1))*FRACUNIT
	local dec = src:sub(decPlace + 1)
	local decNumber = tonumber(dec)*FRACUNIT

	for i = 1, dec:len() do
		decNumber = $1 / 10
	end

	if src:find("^-") then
		return whole - decNumber
	else
		return whole + decNumber
	end
end
rawset(_G, "J_DoFloatNumber", J_DoFloatNumber)

//
// Thinkers
//

-- if we have noclip, god, colorize, keep them for level change with sum player variables.
local function P_ForceFlagsThink(player)
	player.force_godmode = $ or false
	player.force_noclip = $ or false
	player.force_colorize = $ or false

	// chessy mode
	if (player.force_godmode == true) then
		player.pflags = $ | PF_GODMODE
	else
		player.pflags = $ &~ PF_GODMODE
	end

	// noclippers
	if (player.force_noclip == true) then
		player.pflags = $ | PF_NOCLIP
	else
		player.pflags = $ &~ PF_NOCLIP
	end

	// yeah, dont error out with this
	if not JoeBase.IsValid(player.mo) then return end

	if (player.force_colorize == true) then
		player.mo.colorized = true
	else
		player.mo.colorized = false
	end
end
addHook("PlayerThink", P_ForceFlagsThink)

-- do some effects if we have those flags.
local function P_ForceFlagsEffects()
	for player in players.iterate do
		local mo = player.mo
		local scaled = (3*FRACUNIT)/2

		if not JoeBase.IsValid(mo) then continue end

		if (player.force_godmode) then
			local ghost = P_SpawnGhostMobj(mo)
			ghost.fuse = 2
			ghost.frame = $ | (FF_ADD|FF_TRANS30)

			ghost.spritexscale = scaled
			ghost.spriteyscale = scaled

			P_TeleportMove(ghost, mo.x, mo.y, mo.z)
		end

		if (player.force_noclip) then
			mo.frame = $ | FF_TRANS70
		else
			mo.frame = $ &~ FF_TRANS70
		end
	end
end
addHook("PostThinkFrame", P_ForceFlagsEffects)

-- freeze command effects................
local function P_FreezeThink(player)
	player.is_frozen = $ or false

	local mo = player.mo

	if not JoeBase.IsValid(mo) then return end

	if (player.is_frozen) then
		mo.color = SKINCOLOR_ICY
		mo.colorized = true

		player.powers[pw_nocontrol] = max($, 2)

		/*
		
		local ice_block = P_SpawnMobjFromMobj(player, 0, 0, 0, MT_ICEBLOCK)
		...
		*/
	else
		mo.color = player.skincolor
		mo.colorized = false
	end
end
addHook("PlayerThink", P_FreezeThink)