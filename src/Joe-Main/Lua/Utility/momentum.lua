/*
XMomentum without some stuff that feels kinda bloated 
(why does vanilla sonic even exist?? if you want momentum then hes gone)

Everything made by Frostiikin, edits by Jaden.
*/

if not rawget(_G, "joethings") then
	rawset(_G, "joethings", {})
end

-- cvars to do funnies
joethings.momentum = CV_RegisterVar({
	name = "joe_momentum", 
	defaultvalue = "Off",
	flags = CV_NETVAR, 
	possiblevalue = CV_OnOff
})

joethings.momvfx = CV_RegisterVar({
	name = "joe_momentum-vfx", 
	defaultvalue = "Off", 
	flags = CV_NETVAR, 
	possiblevalue = CV_OnOff
})

states[freeslot("S_KICKDUST")] = {freeslot("SPR_AIDU") or SPR_AIDU, FF_ANIMATE|FF_PAPERSPRITE, 6, nil, 5, 1, S_NULL}

local function IsRunningOnWater(p)
	local waterBlock = p.realmo.floorrover

	if (p.realmo.eflags & MFE_VERTICALFLIP) then
		waterBlock = p.realmo.ceilingrover
	end

	if (waterBlock) then
		return P_CanRunOnWater(p, waterBlock)
	end
end

addHook("PlayerThink", function(p)
	if not joethings.momentum.value then return end
	
	if not p.realmo and p.realmo.valid and p.realmo.health return end
	
	local playertrueangle = p.cmd.angleturn<<16 + R_PointToAngle2(0, 0, p.cmd.forwardmove*FRACUNIT, -p.cmd.sidemove*FRACUNIT)
	if P_GetPlayerControlDirection(p) == 0 or p.realmo.flags2 & MF2_TWOD or twodlevel
	   playertrueangle = p.realmo.angle
	end
	
	if p.lastz == nil
		p.lastz = 0
		p.lastx = 0
		p.lasty = 0
		p.restoremymomentumafteruncurlingpleasethankyouuuuu = 0
	end
	
	/////////////////////////////
	--uncuwl uwu (fuck you code divers you gotta suffer with me)
	--aka uncurl because i want control+f support fucking sue me
	--thanks to switchkaze for helping me make this actually work because this game is a pain in the ass
	p.realmo._prevspin = $ ~= nil and $ or false
	p.realmo._spintime = (p.cmd.buttons & BT_USE) and ($ and $+1 or 1) or 0
	
	if (p.pflags & PF_SPINNING) and p.realmo._prevspin and P_IsObjectOnGround(p.realmo) and p.realmo._spintime == 1 
	and not (p.realmo.skin == "altsonic" or p.realmo.skin == "sms" or p.realmo.skin == "adventuresonic")
	and p.realmo.state != S_PLAY_SPINDASH and not (p.pflags & PF_STARTDASH) and p.dashspeed == 0
		p.pflags = $ & ~(PF_SPINNING)
		p.realmo.state = S_PLAY_RUN
		p.restoremymomentumafteruncurlingpleasethankyouuuuu = FixedHypot(p.realmo.momx, p.realmo.momy)
	end
	p.realmo._prevspin = p.pflags & PF_SPINNING
	
	///////////////////////////////
	if p.lastz > p.realmo.z and P_IsObjectOnGround(p.realmo) and (p.pflags & PF_SPINNING)
		P_Thrust(p.realmo, R_PointToAngle2(p.realmo.x, p.realmo.y, p.lastx, p.lasty)+FixedAngle(180*FRACUNIT), max(0, min((p.realmo.z-p.lastz)/20*-1, 10*p.realmo.scale)))
	end
	p.lastz = p.realmo.z
	p.lastx = p.realmo.x
	p.lasty = p.realmo.y
	--I think this works??? maybe??? It has some issues, there's this one bit in gfz2 where you can abuse the fuck out of it, but eh

	///////////////////////////////
	--Super Transformation handler
	if p.realmo.skin != "robe" and p.realmo.skin != "modernsonic"
		if skins[p.realmo.skin].flags & SF_SUPER or (p.realmo.skin == "juniosonic")
			if (p.realmo.state == S_PLAY_FLY or p.realmo.state == S_PLAY_FLY_TIRED)
				if not p.powers[pw_super]
					p.charflags = $ & ~ SF_SUPER
				end
			else
				--S_StartSound(p.realmo, sfx_zoom)
				p.charflags = $ | SF_SUPER
			end
		end
	end

	// apply runonwater flag when speed
	if (p.speed >= 60*FRACUNIT) and not (skins[p.realmo.skin].flags & SF_RUNONWATER)
		p.charflags = $ | SF_RUNONWATER
	else
		if not (skins[p.realmo.skin].flags & SF_RUNONWATER) and p.speed <= 55*FRACUNIT
			p.charflags = $ & ~(SF_RUNONWATER)
		end
	end
end)

-- Custom momentum made with a lot less hacks then CBWMom, heavily referenced from ChrispyChars. 
addHook("PreThinkFrame", function()
	for player in players.iterate do
		if not joethings.momentum.value then continue end

		local mo = player.realmo
		
		if player.xmlastz == nil
			player.xmlastspeed = player.speed
			player.xmlastz = mo.z
			player.xmlastx = mo.x
			player.xmlasty = mo.y
			player.xmlaststate = mo.state
		end

		if player.fakenormalspeed == nil
			player.fakenormalspeed = skins[mo.skin].normalspeed
		end
		
		local watermul = 1
		if (mo.eflags & MFE_UNDERWATER)
			watermul = 2
		end
		
		if (mo and mo.valid and mo.health)
			if player.xmlastskin and player.xmlastskin != mo.skin
				player.hasnomomentum = false
			end
			player.xmlastskin = mo.skin
		end
		
		local speed = FixedDiv(FixedHypot(mo.momx - player.cmomx, mo.momy - player.cmomy), mo.scale)
		local SPEED_INCREASE_LEEWAY = 0*FRACUNIT // the amount of speed above normalspeed needed to update normalspeed
		local SPEED_DECREASE_LEEWAY = 15*FRACUNIT // the amount of speed below normalspeed needed to update normalspeed
		
		if not player.hasnomomentum and not (player.pflags & PF_SPINNING)
			if player.restoremymomentumafteruncurlingpleasethankyouuuuu
				player.normalspeed = max(player.restoremymomentumafteruncurlingpleasethankyouuuuu, player.fakenormalspeed)
				player.restoremymomentumafteruncurlingpleasethankyouuuuu = nil
			end
		
			if player.xmlastz*P_MobjFlip(mo) > mo.z*P_MobjFlip(mo) and P_IsObjectOnGround(mo) and not (mo.eflags & MFE_JUSTHITFLOOR)
				player.normalspeed = $ + (mo.z*P_MobjFlip(mo)-player.xmlastz*P_MobjFlip(mo))/25*-1
		
			elseif player.powers[pw_super] --and player.hyper and player.hyper.capable
				if P_IsObjectOnGround(mo)
					player.normalspeed = $ + FRACUNIT/3
				end
			else
				if P_IsObjectOnGround(mo)
					player.normalspeed = $ + FRACUNIT/15
				end
			end
			
			--temporarily restoring how metal used to work in 1.2 
			--since I wouldn't want to make a major change to gameplay in a minor update
			local restorefakenormalspeed = player.fakenormalspeed
			if player.dashmode > 3*TICRATE
				player.fakenormalspeed = player.normalspeed
			end
			
			if not player.powers[pw_super] and not player.powers[pw_sneakers]
				if (speed*watermul > player.normalspeed + SPEED_INCREASE_LEEWAY
				or speed*watermul < player.normalspeed - SPEED_DECREASE_LEEWAY)
					player.normalspeed = max(speed*watermul, player.fakenormalspeed)
				end
			else
				if (speed*3/5*watermul > player.normalspeed + SPEED_INCREASE_LEEWAY
				or speed*3/5*watermul < player.normalspeed - SPEED_DECREASE_LEEWAY)
					player.normalspeed = max((speed*3/5)*watermul, player.fakenormalspeed)
				end
			end 
			
			player.fakenormalspeed = restorefakenormalspeed
			if player.normalspeed > 145*FRACUNIT*watermul
				player.normalspeed = $ - player.normalspeed/50
			end
		end
		
		player.xmlastspeed = player.speed
		player.xmlastz = mo.z
		player.xmlastx = mo.x
		player.xmlasty = mo.y
		player.xmlaststate = mo.state
	end
end)

// effects that apply to momentum for some reason
local function P_SpawnCoolSkidDust(player, radius, sound)
    local particle = P_SpawnMobjFromMobj(player.realmo, 0, 0, 0, MT_SPINDUST)
    local xn = P_RandomChance(FRACUNIT/2)
    local yn = P_RandomChance(FRACUNIT/2)
    if xn then xn = -1 else xn = 1 end
    if yn then yn = -1 else yn = 1 end

    local x = particle.x + (xn * (FixedMul(radius,P_RandomFixed()) << FRACBITS))
    local y = particle.y + (yn * (FixedMul(radius,P_RandomFixed()) << FRACBITS))
    local z = particle.z --+ (P_RandomRange(0, FRACUNIT-1))
    P_TeleportMove(particle, x, y, z)
    particle.tics = 10
    particle.scale = (2*player.realmo.scale)/3
    particle.momx = player.realmo.momx/4
    particle.momy = player.realmo.momy/4
    P_SetScale(particle, particle.destscale)
    P_SetObjectMomZ(particle, FRACUNIT, false)
    if player.powers[pw_super] then
        P_SetObjectMomZ(particle, FRACUNIT*3, false)
    end

    if player.realmo.eflags & (MFE_TOUCHWATER|MFE_UNDERWATER) then -- smoke looks weird underwater
        particle.state = S_SPLISH1
    end

    if sound then
        S_StartSound(player.realmo, sfx_s3k7e)
    end
    return particle -- the one thing the original version of this didn't do, smh smh
end

addHook("PlayerThink", function(player)
	-- again
	if not joethings.momvfx.value then return end

	local mo = player.realmo
	
	// falling animations over airwalk
	if mo.skin ~= "adventuresonic" then
		for _, CRValues in ipairs({CR_ROLLOUT, CR_MINECART, CR_ZOOMTUBE, CR_ROPEHANG, CR_PLAYER, CR_NIGHTSMODE}) do
			if player.panim == PA_IDLE or player.panim == PA_WALK or player.panim == PA_RUN 
				if not P_IsObjectOnGround(mo) and player.powers[pw_carry] ~= CRValues
					if mo.momz >= 0
						mo.state = S_PLAY_SPRING
					else
						mo.state = S_PLAY_FALL
					end
				end
			end
		end
	end

	// speed parmticle :3
    if P_IsObjectOnGround(mo) and (player.speed > player.runspeed) then
        local part = P_SpawnCoolSkidDust(player, 16, false)
        part.destscale = mo.scale/6+mo.scale/5
        part.scalespeed = FRACUNIT/19
        
        if P_IsObjectOnGround(player.mo) and not (mo.eflags & (MFE_TOUCHWATER|MFE_UNDERWATER)) and 
        (player.speed > 64*FRACUNIT or (player.speed > 50*FRACUNIT and (player.powers[pw_sneakers] or player.dashmode >= 3*TICRATE))) then
            local part2 = P_SpawnCoolSkidDust(player, 12, false)
            part2.state = S_SPINDUST_FIRE1
            part2.destscale = mo.scale/2+mo.scale/11
            part2.scalespeed = FRACUNIT/30
            part2.tics = TICRATE
        end
    end
	
	// watre thinger
	if (player.speed >= 60*FRACUNIT) and (leveltime % 3 == 0) and P_IsObjectOnGround(mo) and mo.eflags & MFE_TOUCHWATER and not (P_PlayerTouchingSectorSpecial(player, 1, 3))
		for i = -1, 1, 2 do
			local ang = i * ANG10
			local factor = FixedMul(4*mo.scale, cos(ang))
			local x = P_ReturnThrustX(mo, player.drawangle + ANGLE_180 + ang, 24*mo.scale)
			local y = P_ReturnThrustY(mo, player.drawangle + ANGLE_180 + ang, 24*mo.scale)
			local dust = P_SpawnMobjFromMobj(mo, x, y, 0, MT_THOK)
			
			dust.scale = 2*$/3
			dust.angle = R_PointToAngle2(dust.x, dust.y, mo.x, mo.y)
			dust.state = S_KICKDUST
			dust.momx = FixedMul(factor, cos(dust.angle - i*ANGLE_90))
			dust.momy = FixedMul(factor, sin(dust.angle - i*ANGLE_90))
		end
	end
end)