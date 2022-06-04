// Load the files so it can be more organized.

local folder = ""
local dofolder = function(file)
	dofile(folder .. "/" .. file)
end

dofile("base.lua")

//
// HUD stuff...
//

folder = "HUD/Custom Rankings"
dofolder("customrankings_coop.lua")
dofolder("customrankings_match.lua")

folder = "HUD/Custom Replacements"
dofolder("funcs.lua")
dofolder("intermission.lua")
--dofolder("titlecard.lua") //disabled until further inspiration.

folder = "HUD"
dofolder("customhud.lua")

//
// Gameplay stuff...
//

folder = "Gameplay/FunkyTools"
dofolder("funky_logic.lua")
dofolder("funky_cmds.lua")

folder = "Gameplay"
dofolder("funnydeath.lua")
dofolder("mpemblems.lua")

//
// Misc stuff...
//

folder = "Misc"
dofolder("customchat.lua")