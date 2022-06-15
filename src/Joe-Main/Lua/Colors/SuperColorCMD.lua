local function SuperColor(p, str)
   	if not (p and p.mo and p.mo.valid) then
        CONS_Printf(p, "You must be in a level to use this.")
        return
    end

	if not str then
		if p.scolorstring == nil then
			CONS_Printf(p,"supercolor " .. "\x87[argument]" .. "\x80 - This command will change your super color. Use 'list' as an argument to see what colors you can use!")
		else
			CONS_Printf(p,"supercolor " .. "\x87[argument]" .. "\x80 - This command will change your super color. Use 'list' as an argument to see what colors you can use!")
		end
		return
	end

	str = $:lower()
	
	if str == "list" then
		CONS_Printf(p,
		"\n" ..
		
		"List of valid Super Colors are:\n" ..
		
		"\n" ..
		
		"Base Game Super Colors\n" ..
		"----------------\n" ..
		
		"\x85"+"Red\n" ..
		"\x87"+"Orange\n" ..
		"\x82"+"Gold\n" ..
		"\x8B"+"Peridot\n" ..
		"\x88"+"Sky\n" ..
		"\x89"+"Purple\n" ..
		"\x87"+"Rust\n" ..
		"\x8D"+"Tan\n" ..
		"\x86"+"Silver\n" ..
		"\n" ..
		
		"\x80"+"Extra Super Colors\n" ..
		"------------\n" ..
		
		"\x83"+"Mint\n" ..
		"\x81"+"Bubblegum\n" ..
		"\x84"+"Sapphire\n" ..
		"\x88"+"Wave\n" ..
		"\x87"+"Copper\n" ..
		"\x85"+"Ruby\n" ..
		"\x80"+"Aether\n" ..
		"\x85"+"Burning\n" ..
		"\x83"+"Emerald\n" ..
		"\x89"+"Lavender\n" ..
		"\x8E"+"Rosy\n" ..
		"\x81"+"Raspberry\n" ..
		"\x84"+"Dark\n" ..
		"\x8D"+"Brown\n" ..
		"\x81"+"Magenta\n" ..
		"\x89"+"PurpleRust\n" ..
		"\x82"+"RedGold\n" ..
		"\x85"+"RoseGold\n" ..
		"\x84"+"Cobalt\n" ..
		"\x87"+"Sunset\n" ..
		"\x86"+"Jet\n" ..
		"\x82"+"Topaz\n" ..
		"\x88"+"Aquatic\n" ..
		"\x89"+"Grape\n" ..
		"\x82"+"Lemon\n" ..
		"\x86"+"Chrome\n" ..
		"\x82"+"Radiance\n" ..
		"\x87"+"Discovery\n" ..
		"\x85"+"Redemption\n" ..
		"\x8E"+"Lovestruck\n" ..
		"\x83"+"Vortex\n" ..
		"\x8F"+"Hyper\n" ..
		"\n" ..
		"\x80"+"None\n" ..
		"\n" ..
		
		"Use the Page Up/Page Down keys to scroll the list."..
		"If you happen to know the internal name of a super color not part of this list, you can use that too!" ..
		"\n")
	
	elseif str == "default" then
		p.scolor = str
		p.scolorstring = "Default"
		CONS_Printf(p,"Super Color set to Default!")
	
	elseif str == "none" then
		p.scolor = str
		p.scolorstring = "None"
		CONS_Printf(p,"Super Color set to None!")
	
	elseif R_GetSuperColorByName(str) then
		p.scolor = R_GetSuperColorByName(str)
		if R_GetColorByName(str) then
			CONS_Printf(p,"Super Color set!")
		else
			CONS_Printf(p,"Super Color set!")
		end
	else
		CONS_Printf(p, "\x82" .. str .. "\x80 is not a valid Super Color.")
	end
end

COM_AddCommand("supercolor", SuperColor)

addHook("PlayerThink", function(p)
	if not (p and p.mo and p.mo.valid and p.powers[pw_super]) then return end
	if (p.scolor == "default" or p.scolor == nil) then return end
	
	if (p.scolor == "none") then
		if (p.pflags & PF_GODMODE) then
			p.mo.color = p.skincolor
		else
			p.mo.color = p.skincolor
		end

	elseif p.scolor then
		for i = 0, 4 do
			if p.mo.color == skins[p.mo.skin].supercolor + i then
				if (p.pflags & PF_GODMODE) then
					p.mo.color = p.scolor + i
				else
					p.mo.color = p.scolor + i
				end
			end
		end
	end
end)

-- 2.2.10 will let this hook set the ghost's colors properly, too.
addHook("MobjThinker", function(ghost)
	if ghost and ghost.valid
	and ghost.target and ghost.target.valid and ghost.target.player then
		if ghost.target.player.powers[pw_super] >= 2 then
			ghost.color = ghost.target.color
		end
	end
end, MT_GHOST)