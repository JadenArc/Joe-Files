/*
None of the code here was taken from movienight despite the similar functionality.
This is just a script that allows you to see who is spectating you. WIP
You can use this code however you like. Made by gameing server guy
*/

freeslot("MT_VSSPECTATORICON","S_VSSPECTATORICON")

mobjinfo[MT_VSSPECTATORICON] = {
	doomednum = -1,
	spawnstate = S_VSSPECTATORICON,
	flags = mobjinfo[MT_PITY_ORB].flags
}
states[S_VSSPECTATORICON] = {sprite = SPR_PLAY, frame = FF_FULLBRIGHT|A, tics = -1}

local VSviewplayer = nil

addHook("MapChange", function()
	if netgame then
		for player in players.iterate do
			player.VSaudience = {}
			player.VSspectating = nil
			player.VSmessagetimer = 0
		end
	end
end)

COM_AddCommand("__VSignore", function(player, stplyrindex)
	if netgame then player.VSspectating = tonumber(stplyrindex) end
end)

addHook("PlayerMsg", function(source, msgtype, target, msg)
	if msgtype == 0 and netgame then source.VSmessagetimer = TICRATE * 5 end
end)

addHook("MobjThinker", function(mobj)
	if not (mobj.target and mobj.target.player and mobj.target.player.VSspectating ~= #mobj.target.player) then
		P_RemoveMobj(mobj)
		return
	end
	
	if mobj.skin ~= players[mobj.target.player.VSspectating].realmo.skin
	or mobj.color ~= players[mobj.target.player.VSspectating].realmo.color then
		mobj.skin = players[mobj.target.player.VSspectating].realmo.skin
		mobj.color = players[mobj.target.player.VSspectating].realmo.color
		mobj.sprite2 = SPR2_LIFE
	end
	
	if not (mobj.eflags & MFE_VERTICALFLIP) then
		P_TeleportMove(mobj,
		mobj.target.x,
		mobj.target.y,
		mobj.target.z + ((((mobj.target.height / FRACUNIT) + 12) * (mobj.target.scale / FRACUNIT)) * FRACUNIT))
	else
		P_TeleportMove(mobj,
		mobj.target.x,
		mobj.target.y,
		mobj.target.z - ((12 * (mobj.target.scale / FRACUNIT)) * FRACUNIT))
	end
	
	if mobj.target.eflags & MFE_VERTICALFLIP then
		if not (mobj.eflags & MFE_VERTICALFLIP) then mobj.eflags  = $1|MFE_VERTICALFLIP end
	else
		if mobj.eflags & MFE_VERTICALFLIP then
			mobj.eflags = $1 & ~MFE_VERTICALFLIP
		end
	end
end, MT_VSSPECTATORICON)

addHook("HUD", function(v, stplyr)
	if netgame then VSviewplayer = stplyr end
	
	if (stplyr.VSaudience and stplyr.VSspectating ~= nil and netgame) then
		for i = 23, 30 do
			if stplyr.VSaudience[i] ~= nil and players[stplyr.VSaudience[i]] then
				v.drawScaled(
					FRACUNIT * ((302 + 20) - (14 * (i - 23))),
					FRACUNIT * (205 - 30),
					skins[players[stplyr.VSaudience[i]].realmo.skin].highresscale / 2,
					v.getSprite2Patch(
						players[stplyr.VSaudience[i]].realmo.skin,
						players[stplyr.VSaudience[i]].realmo.sprite2 or SPR2_STND,
						players[stplyr.VSaudience[i]].realmo and players[stplyr.VSaudience[i]].realmo.frame or A,
						4
					),
					V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_PERPLAYER,
					v.getColormap(0, players[stplyr.VSaudience[i]].realmo.color)
				)
			end
		end
		
		for i = 15, 22 do
			if stplyr.VSaudience[i] ~= nil and players[stplyr.VSaudience[i]] then
				v.drawScaled(
					FRACUNIT * ((302 + 18) - (14 * (i - 15))),
					FRACUNIT * (205 - 20),
					skins[players[stplyr.VSaudience[i]].realmo.skin].highresscale / 2,
					v.getSprite2Patch(
						players[stplyr.VSaudience[i]].realmo.skin,
						players[stplyr.VSaudience[i]].realmo.sprite2 or SPR2_STND,
						players[stplyr.VSaudience[i]].realmo and players[stplyr.VSaudience[i]].realmo.frame or A,
						4
					),
					V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_PERPLAYER,
					v.getColormap(0, players[stplyr.VSaudience[i]].realmo.color)
				)
				
				if players[stplyr.VSaudience[i]].VSmessagetimer then
					v.drawScaled(
						FRACUNIT * (((302 + 18) - (14 * (i - 15))) - 13),
						FRACUNIT * ((205 - 10) - 6),
						FRACUNIT / 2,
						v.getSpritePatch(SPR_FLII, D),
						V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_PERPLAYER
					)
					
					v.drawFill((((302 + 18) - (14 * (i - 15))) - 2), ((205 - 20) - 36), 4, 5, (V_SNAPTOBOTTOM + V_SNAPTORIGHT))
				end
			end
		end
	
		for i = 7, 14 do
			if stplyr.VSaudience[i] ~= nil and players[stplyr.VSaudience[i]] then
				v.drawScaled(
					FRACUNIT * ((302 + 16) - (14 * (i - 7))),
					FRACUNIT * (205 - 10),
					skins[players[stplyr.VSaudience[i]].realmo.skin].highresscale / 2,
					v.getSprite2Patch(
						players[stplyr.VSaudience[i]].realmo.skin,
						players[stplyr.VSaudience[i]].realmo.sprite2 or SPR2_STND,
						players[stplyr.VSaudience[i]].realmo and players[stplyr.VSaudience[i]].realmo.frame or A,
						4
					),
					V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_PERPLAYER,
					v.getColormap(0, players[stplyr.VSaudience[i]].realmo.color)
				)
				
				if players[stplyr.VSaudience[i]].VSmessagetimer then
					v.drawScaled(
						FRACUNIT * (((302 + 16) - (14 * (i - 7))) - 13),
						FRACUNIT * ((205 - 10) - 6),
						FRACUNIT / 2,
						v.getSpritePatch(SPR_FLII, D),
						V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_PERPLAYER
					)
					
					v.drawFill((((302 + 16) - (14 * (i - 7))) - 2), ((205 - 10) - 36), 4, 5, (V_SNAPTOBOTTOM + V_SNAPTORIGHT))
				end
			end
		end
		
		for i = 0, 6 do
			if stplyr.VSaudience[i] ~= nil and players[stplyr.VSaudience[i]] then
				v.drawScaled(
					FRACUNIT * (302 - 14 * i),
					FRACUNIT * 205,
					skins[players[stplyr.VSaudience[i]].realmo.skin].highresscale / 2,
					v.getSprite2Patch(
						players[stplyr.VSaudience[i]].realmo.skin,
						players[stplyr.VSaudience[i]].realmo.sprite2 or SPR2_STND,
						players[stplyr.VSaudience[i]].realmo and players[stplyr.VSaudience[i]].realmo.frame or A,
						4
					),
					V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_PERPLAYER,
					v.getColormap(0, players[stplyr.VSaudience[i]].realmo.color)
				)
				
				if players[stplyr.VSaudience[i]].VSmessagetimer then
					v.drawScaled(
						FRACUNIT * ((302 - 14 * i) - 13),
						FRACUNIT * (205 - 6),
						FRACUNIT / 2,
						v.getSpritePatch(SPR_FLII, D),
						V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_PERPLAYER
					)
					
					v.drawFill(((302 - 14 * i) - 2), (205 - 36), 4, 5, (V_SNAPTOBOTTOM + V_SNAPTORIGHT))
				end
			end
		end
		
		if stplyr.VSspectating ~= #stplyr then
			v.fadeScreen(0xFA00, 7)
			v.drawString(160, 91, "Currently Viewing:", V_YELLOWMAP|V_ALLOWLOWERCASE, "center")
			v.drawString(160, 101, players[stplyr.VSspectating].name, V_ALLOWLOWERCASE, "center")
		end
	end
end, "game")

addHook("PlayerThink", function(player)
	if (player.realmo and player.realmo.valid and VSviewplayer ~= nil and netgame) then
		if player.VSmessagetimer then player.VSmessagetimer = $ - 1 end
		
		if (leveltime > 6 * TICRATE) and (player.jointime > 6 * TICRATE) and (leveltime % 2 == 0) then
			COM_BufInsertText(player, "__VSignore " .. #VSviewplayer)
		end
		
		if not player.VSaudience then player.VSaudience = {} end
	
		if player.VSspectating ~= nil then
			if player.VSspectating ~= #player and not (player.realmo.VSspectatoricon and player.realmo.VSspectatoricon.valid) then
				player.realmo.VSspectatoricon = P_SpawnMobjFromMobj(player.realmo, 0, 0, 0, MT_VSSPECTATORICON)
				player.realmo.VSspectatoricon.target = player.realmo
			end
			
			for i = 0, 31 do
				if player.VSaudience[i] ~= nil
				and (players[player.VSaudience[i]] == nil or players[player.VSaudience[i]].VSspectating ~= #player) then
					player.VSaudience[i] = nil
				end
				
				if player.VSspectating ~= #player then
					for i = 0, 31 do
						if players[player.VSspectating].VSaudience[i] == #player then return end
					end
					
					if players[player.VSspectating].VSaudience[i] == nil then
						players[player.VSspectating].VSaudience[i] = #player
					end
				end
			end
		end
	end
end)