--
-- Original script by wired-aunt.
--

local sorted_players = {}

local cv_nametags = CV_RegisterVar({
	name = "nametags",
	defaultvalue = "On",
	flags = CV_MODIFIED,
	PossibleValue = CV_OnOff
})

local cv_showownname = CV_RegisterVar({
	name = "nametags_showown",
	defaultvalue = "Off",
	flags = CV_MODIFIED,
	PossibleValue = CV_OnOff
})

addHook("HUD", function(v, player, camera)
	if not cv_nametags.value then return end

	local width = 320
	local height = 200
	local realwidth = v.width()/v.dupx()
	local realheight = v.height()/v.dupy()

	local first_person = not camera.chase
	local cam = first_person and player.realmo or camera
	local spectator = player.spectator
	
	local hudwidth = 320*FRACUNIT
	local hudheight = (320*v.height()/v.width()) * FRACUNIT

	local fov = (CV_FindVar("fov").value/FRACUNIT) * ANG1 --Can this be fetched live instead of assumed?
	
	--the "distance" the HUD plane is projected from the player
	local hud_distance = FixedDiv(hudwidth / 2, tan(fov/2))

	for _, target_player in pairs(sorted_players) do
		local tmo = target_player.mo

		if (target_player.spectator) or not (tmo and tmo.valid) then continue end
		if (not cv_showownname.value) and (player == target_player) then continue end

		--how far away is the other player?
		local distance = R_PointToDist(tmo.x, tmo.y)

		local distlimit = 1000
		if distance > distlimit*FRACUNIT then continue end

		--Angle between camera vector and target
		local hangdiff = R_PointToAngle2(cam.x, cam.y, tmo.x, tmo.y)
		local hangle = hangdiff - cam.angle

		--check if object is outside of our field of view
		--converting to fixed just to normalise things
		--e.g. this will convert 365° to 5° for us
		local fhanlge = AngleFixed(hangle)
		local fhfov = AngleFixed(fov/2)
		local f360 = AngleFixed(ANGLE_MAX)
		
		if (fhanlge < f360 - fhfov) and (fhanlge > fhfov) then
			continue
		end
		
		--flipcam adjustment
		local flip = 1
		if displayplayer.mo and displayplayer.mo.valid
			flip = P_MobjFlip(displayplayer.mo)
		end

		--figure out vertical angle
		local h = FixedHypot(cam.x-tmo.x, cam.y-tmo.y)
		local tmoz = tmo.z
		
		if (flip == -1) then
			tmoz = tmo.z + tmo.height
		end
		
		if spectator then
			tmoz = $ - 48*tmo.scale
		end
		
		local vangdiff = R_PointToAngle2(0, 0, tmoz - cam.z + (62*FRACUNIT) * flip, h) - ANGLE_90
		local vcangle = first_person and player.aiming or cam.aiming or 0
		
		local vangle = (vcangle + vangdiff) * flip

		--again just check if we're outside the FOV
		local fvangle = AngleFixed(vangle)
		local fvfov = FixedMul(AngleFixed(fov), FRACUNIT * v.height()/v.width())
		
		if (fvangle < f360 - fvfov) and (fvangle > fvfov) then
			continue
		end

		local hpos = hudwidth/2 - FixedMul(hud_distance, tan(hangle) * realwidth/width)
		local vpos = hudheight/2 + FixedMul(hud_distance, tan(vangle) * realheight/height)

		local name = target_player.name
		local namefont = "thin-fixed-center"
		local nameflags = (target_player.skincolor > 0) and skincolors[target_player.skincolor].chatcolor or 0
	
		local distedit = max(0, distance - (distlimit*FRACUNIT/2)) * 2
		local trans = min(9, (((distedit * 10) / FRACUNIT) / distlimit)) * V_10TRANS
	
		v.drawString(hpos, vpos, name, nameflags|trans|V_ALLOWLOWERCASE, namefont)
	end
end, "game")

addHook("PostThinkFrame", function()
	sorted_players = {}
	
	for player in players.iterate() do
		if player and player.valid and player.mo and player.mo.valid then
			if displayplayer and displayplayer.realmo and displayplayer.realmo.valid
				local thok = P_SpawnMobj(camera.x, camera.y, camera.z, MT_THOK)
				local sight = P_CheckSight(thok, player.mo)
				
				P_RemoveMobj(thok)
				
				if not sight then continue end
			end
			table.insert(sorted_players, player)
		end
	end
	--This list will be different for every player in a network game
	--Don't use it for anything other than HUD drawing
	table.sort(sorted_players, function(a, b)
		return R_PointToDist(a.mo.x, a.mo.y) > R_PointToDist(b.mo.x, b.mo.y)
	end)
end)