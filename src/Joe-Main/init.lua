local folder = ""
local function dofolder(file)
	dofile(folder .. "/" .. file)
end

//
// Everything else
//

-- Colors
folder = "Utility/Colors"
dofolder('MegaPaintColor.lua')
dofolder('SuperColorCMD.lua')
dofolder('SuperFreeslots.lua')

-- Resources
folder = "Utility/Resources"
dofolder('corkbuff.lua')
dofolder('joinandleavesounds.lua')
dofolder('spectators.lua')
	
-- ExitTimer
folder = "Utility/ExitTimer"
dofolder('ExitTimerLogic.lua')
dofolder('ExitTimerHUD.lua')
	
-- General
folder = "Utility"
dofolder('afk.lua')
dofolder('banskins.lua')
dofolder('RTV.lua')
dofolder('tipmessages.lua')
dofolder('momentum.lua')
dofolder('nametags.lua')

//
// Some cool thing
//

folder = 'Custom Menu'
dofolder("menu_defs.lua")
dofolder("menu_func.lua")

//
//
// Functions
//
//

rawset(_G, "DidFinish", function(player)
	return ((player.pflags & PF_FINISHED) or ((player.exiting > 0) and not player.afk)) and not player.outofcoop and not (player.quittime > 0)
end)

rawset(_G, "M_DrawBox", function(v, x, y, width, boxlines, flags)
	// Solid color textbox, with a black box behind.
	v.drawFill(x + 6, y + 6, (width*8) + 7, (boxlines*8) + 7, 31|flags)
	v.drawFill(x + 5, y + 5, (width*8) + 6, (boxlines*8) + 6, 159|flags)
end)