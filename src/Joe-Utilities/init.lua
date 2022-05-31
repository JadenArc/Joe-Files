// Load the files so it can be more organized.

local folder = ""
local dofolder = function(file)
	dofile(folder .. "/" .. file)
end

dofile("base.lua")

folder = "HUD/Custom Rankings"
dofolder("customrankings_coop.lua")
dofolder("customrankings_match.lua")

folder = "HUD/Custom Replacements"
dofolder("funcs.lua")
dofolder("intermission.lua")
dofolder("titlecard.lua")

folder = "HUD"
dofolder("customhud.lua")

folder = "Gameplay"
dofolder("funkytools.lua")
dofolder("funnydeath.lua")
dofolder("mpemblems.lua")

folder = "Misc"
dofolder("customchat.lua")