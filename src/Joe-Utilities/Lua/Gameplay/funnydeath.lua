//
-- Funny deaths
-- By Jaden

-- clearly inspired from a Kart mod with the same name
//

freeslot("S_STOCKBOOM", "SPR_BLOL")
freeslot("sfx_sboom", "sfx_splat", "sfx_slip")

states[S_STOCKBOOM] = {SPR_BLOL, A|FF_ANIMATE, 17, nil, 16, 1, S_NULL}

sfxinfo[sfx_sboom] = {caption = "Boom!", flags = SF_X2AWAYSOUND}
sfxinfo[sfx_splat] = {caption = "Squished", flags = SF_X2AWAYSOUND}
sfxinfo[sfx_slip] = {caption = "Banana Peel", flags = SF_X2AWAYSOUND}

local SkinBlacklist = { -- i forgor more skins (perhaps)
	["adventuresonic"] = true,
	["milne"] = true,
	["iclyn"] = true,
	["jellytails"] = true,
	["bowser"] = true,
	["tailsdoll"] = true,
	["plagueknight"] = true,
	["kirby"] = true,
	["kiryu"] = true
}

local dmtype

// This is kinda simple...
local P_DoSquishDeath = function(player)
	local mo = player.mo

	mo.state = S_PLAY_DEAD
	mo.frame = $ | FF_FLOORSPRITE
end

// This, nah.
local P_DoExplosionDeath = function(player)
	local mo = player.mo

	if (mo.fuse > 1) then
		P_InstaThrust(mo, mo.angle, -10*FRACUNIT)

		mo.state = S_PLAY_PAIN
			
		player.drawangle = $ + ANG15
		mo.rollangle = $ + ANG20
	end
				
	if (mo.fuse == 1) then
		local boom = P_SpawnMobjFromMobj(mo, mo.x, mo.y, mo.z, MT_THOK)
		boom.state = S_STOCKBOOM
		boom.fuse = TICRATE
		P_TeleportMove(boom, mo.x, mo.y, mo.z)
					
		S_StartSound(mo, sfx_sboom)
			
		mo.state = S_INVISIBLE
		mo.momx, mo.momy, mo.momz = 0, 0, 0

		-- do some quakes, and flashes!
		if player == displayplayer then
			P_FlashPal(player, PAL_WHITE, 3)
			P_StartQuake(8*FRACUNIT, 10)
		end
	end
end

local function DeathLogic(player)
	if not (player.mo) then return end 

	local mo = player.mo

	if (player.playerstate == PST_DEAD) then
		if (SkinBlacklist[mo.skin] == true) then return end

		if (dmtype == DMG_CRUSHED) then
			P_DoSquishDeath(player)
		else
			P_DoExplosionDeath(player)
		end
	end
end

// :v
local function ActualDeathLogic(mo, inf, src, dmt)
	local player = mo.player

	if (SkinBlacklist[mo.skin] == true) then return end

	// squish squash!
	if (dmt == DMG_CRUSHED) then
		mo.flags = $ &~ (MF_NOCLIP|MF_NOCLIPHEIGHT)

		mo.height = 0
		mo.fuse = -1
		mo.shadowscale = 0

		S_StartSound(mo, sfx_splat)

	// boom!
	else
		mo.flags = $ | MF_NOGRAVITY &~ (MF_NOCLIP|MF_NOCLIPHEIGHT)
					
		mo.momx, mo.momy = $1 / 4, $2 / 4
		mo.fuse = 30

		P_SetObjectMomZ(mo, 16*FRACUNIT, false)

		S_StartSound(mo, sfx_slip)
	end

	dmtype = dmt
	
	-- lol
	if (player.lives ~= INFLIVES) and G_GametypeUsesLives() then
		if not (player.pflags & PF_FINISHED) then
			player.lives = $ - 1
		end

		if (player.lives < 0) then
			player.lives = 0
		end
	end
	
	return true
end

addHook("MobjDeath", ActualDeathLogic, MT_PLAYER)
addHook("PlayerThink", DeathLogic)