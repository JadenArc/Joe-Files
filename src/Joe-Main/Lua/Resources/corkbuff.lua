-- cork buff
mobjinfo[MT_CORK].speed = 48*FRACUNIT -- Balance tweak to preserve some of the challenge

addHook("MobjSpawn",function(mo)
	return true -- Overwrite default behavior so that corks won't damage invulnerable players
end, MT_CORK)

//Add ghost trail to the cork to improve its visibility
addHook("MobjThinker",function(mo)
	if mo.flags & MF_MISSILE and mo.target and mo.target.player then
		local ghost = P_SpawnGhostMobj(mo)
		ghost.destscale = ghost.scale*4
		ghost.blendmode = AST_ADD
	
		if not (gametyperules & GTR_FRIENDLY) then -- Add color trail to competitive gametypes
			ghost.colorized = true
			ghost.color = mo.target.player.skincolor
			ghost.blendmode = AST_ADD
		end
	end
end, MT_CORK)