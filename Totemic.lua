local _, class = UnitClass("player")
if class ~= "SHAMAN" then
	return
end

local TOTEMIC_VERSION = "1.0.0"

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Totemic|r: Starting...")

local totemSpells = {
	{ element = "Earth", name = "Earthbind Totem" },
	{ element = "Earth", name = "Tremor Totem" },
	{ element = "Earth", name = "Strength of Earth Totem" },
	{ element = "Earth", name = "Stoneskin Totem" },
	{ element = "Earth", name = "Stoneclaw Totem" },
	{ element = "Fire", name = "Searing Totem" },
	{ element = "Fire", name = "Fire Nova Totem" },
	{ element = "Fire", name = "Magma Totem" },
	{ element = "Fire", name = "Frost Resistance Totem" },
	{ element = "Fire", name = "Flametongue Totem" },
	{ element = "Water", name = "Mana Spring Totem" },
	{ element = "Water", name = "Fire Resistance Totem" },
	{ element = "Water", name = "Poison Cleansing Totem" },
	{ element = "Water", name = "Disease Cleansing Totem" },
	{ element = "Water", name = "Healing Stream Totem" },
	{ element = "Air", name = "Tranquil Air Totem" },
	{ element = "Air", name = "Grounding Totem" },
	{ element = "Air", name = "Windfury Totem" },
	{ element = "Air", name = "Grace of Air Totem" },
	{ element = "Air", name = "Nature Resistance Totem" },
	{ element = "Air", name = "Windwall Totem" },
	{ element = "Air", name = "Sentry Totem" }
}

local elementButtons = {
	[1] = "TotemicEarth",
	[2] = "TotemicFire", 
	[3] = "TotemicWater",
	[4] = "TotemicAir"
}

local elementNames = {
	[1] = "Earth",
	[2] = "Fire",
	[3] = "Water",
	[4] = "Air"
}

local elementIndex = {
	Earth = 1,
	Fire = 2,
	Water = 3,
	Air = 4
}

function Totemic_FindSpell(name)
	for i = 1, 400 do
		local spellName = GetSpellName(i, BOOKTYPE_SPELL)
		if spellName and spellName == name then
			return i
		end
	end
	return nil
end

function Totemic_ScanSpells()
	local found = { Earth = false, Fire = false, Water = false, Air = false }
	
	for id, data in ipairs(totemSpells) do
		local spellId = Totemic_FindSpell(data.name)
		if spellId then
			found[data.element] = true
		end
	end
	
	for element, hasLearned in pairs(found) do
		local btn = elementButtons[elementIndex[element]]
		if btn and _G[btn] then
			if hasLearned then
				_G[btn]:Show()
			else
				_G[btn]:Hide()
			end
		end
	end
	
	if not (found.Earth or found.Fire or found.Water or found.Air) then
		DEFAULT_CHAT_FRAME:AddMessage("No totems found!")
	end
end

function Totemic_CastTotem(id)
	local element = elementNames[id]
	if not element then return end
	
	for _, data in ipairs(totemSpells) do
		if data.element == element then
			local spellId = Totemic_FindSpell(data.name)
			if spellId then
				CastSpellByName(data.name)
				return
			end
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage("No " .. element .. " totem learned!")
end

SLASH_TOTEMIC1 = "/totemic"
SlashCmdList["TOTEMIC"] = function(msg)
	if msg == "show" or msg == "" then
		TotemicFrame:Show()
	elseif msg == "hide" then
		TotemicFrame:Hide()
	end
end

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Totemic|r v" .. TOTEMIC_VERSION .. " loaded.")

TotemicFrame:Show()

Totemic_ScanSpells()
