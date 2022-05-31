freeslot("sfx_join", "sfx_leave", "sfx_syfail")

sfxinfo[sfx_join].caption = "Player Joined"
sfxinfo[sfx_leave].caption = "Player Left"
sfxinfo[sfx_syfail].caption = "Player Banned/Kicked"

addHook("PlayerJoin", function(playernum)
	S_StartSound(nil, sfx_join, nil)
end)

addHook("PlayerQuit", function(player, reason)
	if reason == KR_LEAVE then
		S_StartSound(nil, sfx_leave, nil)
	elseif reason == (KR_KICK or KR_BAN or KR_SYNCH or KR_TIMEOUT or KR_PINGLIMIT) then
		S_StartSound(nil, sfx_syfail, nil)
	end
end)