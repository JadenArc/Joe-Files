local folder = ""
local function dofolder(file)
	dofile(folder .. "/" .. file)
end

//
// Everything else
//

-- Colors
folder = "Colors"
dofolder('MegaPaintColor.lua')
dofolder('SuperColorCMD.lua')
dofolder('SuperFreeslots.lua')

-- Resources
folder = "Resources"
dofolder('corkbuff.lua')
dofolder('joinandleavesounds.lua')
dofolder('spectators.lua')
	
-- ExitTimer
folder = "ExitTimer"
dofolder('ExitTimerLogic.lua')
dofolder('ExitTimerHUD.lua')
	
-- General
dofile('afk.lua')
dofile('banskins.lua')
dofile('RTV.lua')
dofile('tipmessages.lua')
dofile('momentum.lua')
dofile('nametags.lua')

//
//
// Functions
//
//

rawset(_G, "DidFinish", function(player)
	return ((player.pflags & PF_FINISHED) and not player.afk) and not (player.quittime > 0)
end)

rawset(_G, "M_DrawBox", function(v, x, y, width, boxlines, flags)
	// Solid color textbox, with a black box behind.
	v.drawFill(x + 6, y + 6, (width*8) + 7, (boxlines*8) + 7, 31|flags)
	v.drawFill(x + 5, y + 5, (width*8) + 6, (boxlines*8) + 6, 159|flags)
end)