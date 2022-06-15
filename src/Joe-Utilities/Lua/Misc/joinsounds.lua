//
-- The most self-explanatory script ever
-- By Jaden
//

freeslot("sfx_join", "sfx_leave", "sfx_syfail", "sfx_kick")

sfxinfo[sfx_join].caption = "Player Joined"
sfxinfo[sfx_leave].caption = "Player Left"
sfxinfo[sfx_syfail].caption = "Sync Failure"
sfxinfo[sfx_kick].caption = "Kicked/Banned"

local syncfails = {KR_SYNCH, KR_TIMEOUT, KR_PINGLIMIT}
local kickfails = {KR_KICK, KR_BAN}

addHook("PlayerJoin", function(playernum)
	S_StartSound(nil, sfx_join, nil)
end)

addHook("PlayerQuit", function(player, reason)
	if (reason == KR_LEAVE) then
		S_StartSound(nil, sfx_leave, nil)
	end
	
	for _, syncs in ipairs(syncfails) do
		if (reason == syncs) then
			S_StartSound(nil, sfx_syfail, nil)
		end
	end
	
	for _, kicks in ipairs(kickfails) do
		if (reason == kicks) then
			S_StartSound(nil, sfx_kick, nil)
		end
	end
end)