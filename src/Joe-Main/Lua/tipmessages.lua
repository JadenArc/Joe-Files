-- what messages are going to be showed

freeslot("sfx_tpmess")
sfxinfo[sfx_tpmess].caption = "Tip"

local tiptimer = 0
local UselessTips = { 
	"Are you tired of this stage, and the admins arent around to change it? Type \130rtv \128in the chat to call a vote to skip the current stage!",
	"Type \130super \128in your console to become super!",
	"Do you want another supercolor? Type \130supercolor <supercolor> \128in your console to set one. To see the list, type \130supercolor list.",
	"Use the \130colorize \128command to colorize/uncolorize yourself.",
	"You can get rings by using the \130rings \128command. The amounts are from 0 to 9999.",
	"Type \130scale \128on your console to be bigger than others! There's no limit.",
	"Do you need to do something on the real life? Type \130afk \128on your console to be afk. You will also be invulnerable to everything and be stopped on whatever place you are.",
	"Do you want to join the discord server? Type \130discordlink \128on your console to see the link, and join it!",

	-- jokes
	"\133Joe \128is always here, he is watching you and your every move. All hail \133Joe\128. \133ALL HAIL JOE!",
	"It was \132Richter Belmont\128, the legendary vampire hunter, who succeeded in finally ending the menace of \133Count Dracula\128, Lord of the Vampires who had been brought back from the grave by the dark priest \141Shaft\128.",
	"Stop posting about \133Among Us\128! I'm tired of seeing it!"
}

-- and the thinker!
addHook("ThinkFrame", function()
	if not (gamestate == GS_LEVEL) then return end
	
	if not (netgame or multiplayer) then return end
	if not #UselessTips then return end
	
	tiptimer = $ and $ - 1 or 0
	
	if not tiptimer then
		local chatMessage = "\x81<Joe's Soul> \x80" .. UselessTips[P_RandomRange(1, #UselessTips)]
		chatprint(chatMessage, false)
		
		S_StartSound(nil, sfx_tpmess)
		tiptimer = 150*TICRATE -- 3 minutes
	end
end)

-- and its netvar hook to make it work

addHook("NetVars", function(net)
	tiptimer = net($)
	UselessTips = net($)
end)