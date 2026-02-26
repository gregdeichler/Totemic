local _, class = UnitClass("player")

if class ~= "SHAMAN" then
	return
end

local TOTEMIC_VERSION = "1.0.0"

local totemData = {
	Earth = {
		{ name = "Earthbind Totem", icon = "Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02", cooldown = 15 },
		{ name = "Tremor Totem", icon = "Interface\\Icons\\Spell_Nature_TremorTotem", cooldown = 0 },
		{ name = "Strength of Earth Totem", icon = "Interface\\Icons\\Spell_Nature_EarthBindTotem", cooldown = 0 },
		{ name = "Stoneskin Totem", icon = "Interface\\Icons\\Spell_Nature_StoneSkinTotem", cooldown = 0 },
		{ name = "Stoneclaw Totem", icon = "Interface\\Icons\\Spell_Nature_StoneClawTotem", cooldown = 30 }
	},
	Fire = {
		{ name = "Searing Totem", icon = "Interface\\Icons\\Spell_Fire_SearingTotem", cooldown = 0 },
		{ name = "Fire Nova Totem", icon = "Interface\\Icons\\Spell_Fire_SealOfFire", cooldown = 15 },
		{ name = "Magma Totem", icon = "Interface\\Icons\\Spell_Fire_SelfDestruct", cooldown = 0 },
		{ name = "Frost Resistance Totem", icon = "Interface\\Icons\\Spell_FrostResistanceTotem_01", cooldown = 0 },
		{ name = "Flametongue Totem", icon = "Interface\\Icons\\Spell_Nature_GuardianWard", cooldown = 0 }
	},
	Water = {
		{ name = "Mana Spring Totem", icon = "Interface\\Icons\\Spell_Nature_ManaRegenTotem", cooldown = 0 },
		{ name = "Fire Resistance Totem", icon = "Interface\\Icons\\Spell_FireResistanceTotem_01", cooldown = 0 },
		{ name = "Poison Cleansing Totem", icon = "Interface\\Icons\\Spell_Nature_PoisonCleansingTotem", cooldown = 0 },
		{ name = "Disease Cleansing Totem", icon = "Interface\\Icons\\Spell_Nature_DiseaseCleansingTotem", cooldown = 0 },
		{ name = "Healing Stream Totem", icon = "Interface\\Icons\\INV_Spear_04", cooldown = 0 }
	},
	Air = {
		{ name = "Tranquil Air Totem", icon = "Interface\\Icons\\Spell_Nature_Brilliance", cooldown = 0 },
		{ name = "Grounding Totem", icon = "Interface\\Icons\\Spell_Nature_GroundingTotem", cooldown = 15 },
		{ name = "Windfury Totem", icon = "Interface\\Icons\\Spell_Nature_Windfury", cooldown = 0 },
		{ name = "Grace of Air Totem", icon = "Interface\\Icons\\Spell_Nature_InvisibilityTotem", cooldown = 0 },
		{ name = "Nature Resistance Totem", icon = "Interface\\Icons\\Spell_Nature_NatureResistanceTotem", cooldown = 0 },
		{ name = "Windwall Totem", icon = "Interface\\Icons\\Spell_Nature_EarthBind", cooldown = 0 },
		{ name = "Sentry Totem", icon = "Interface\\Icons\\Spell_Nature_RemoveCurse", cooldown = 0 }
	}
}

local activeTotems = {}
local learnedTotems = {}

local elements = {"Earth", "Fire", "Water", "Air"}

function Totemic_ScanLearnedTotems()
	for _, element in ipairs(elements) do
		local count = 0
		for i, totem in ipairs(totemData[element]) do
			if Totemic_IsSpellLearned(totem.name) then
				count = count + 1
			end
		end
		count = max(count, 1)
		for i = 1, count do
			local button = _G["Totemic" .. element]
			if button then
				button:Show()
			end
		end
		for i = count + 1, 5 do
			local button = _G["Totemic" .. element]
			if button then
				button:Hide()
			end
		end
	end
end

function Totemic_IsSpellLearned(spellName)
	for i = 1, 400 do
		local name = GetSpellName(i, BOOKTYPE_SPELL)
		if name and name == spellName then
			return true
		end
	end
	return false
end

function Totemic_CastTotem(element)
	local count = 0
	for i, totem in ipairs(totemData[element]) do
		if Totemic_IsSpellLearned(totem.name) then
			count = count + 1
		end
	end
	
	for i = 1, count do
		local totem = totemData[element][i]
		CastSpellByName(totem.name)
		activeTotems[element] = {
			name = totem.name,
			castTime = GetTime(),
			cooldown = totem.cooldown
		}
		break
	end
end

function Totemic_UpdateTimers()
	for _, element in ipairs(elements) do
		local totem = activeTotems[element]
		local button = _G["Totemic" .. element]
		local timer = _G["Totemic" .. element .. "Timer"]
		
		if totem and button and timer then
			local elapsed = GetTime() - totem.castTime
			local remaining = totem.cooldown - elapsed
			
			if remaining > 0 then
				timer:SetText(format("%.0f", remaining))
				timer:Show()
			else
				timer:Hide()
				activeTotems[element] = nil
			end
		end
	end
end

function Totemic_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
	this:RegisterEvent("PLAYER_TOTEM_UPDATE")
end

function Totemic_OnEvent(event, arg1)
	if event == "VARIABLES_LOADED" then
		Totemic_ScanLearnedTotems()
		TotemicFrame:Show()
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Totemic|r v" .. TOTEMIC_VERSION .. " loaded.")
	elseif event == "PLAYER_TOTEM_UPDATE" then
		Totemic_ScanLearnedTotems()
	elseif event == "SPELLBOOK_CHANGED" then
		Totemic_ScanLearnedTotems()
	end
end

function Totemic_OnUpdate(arg1)
	this.timer = (this.timer or 0) + arg1
	if this.timer > 0.1 then
		Totemic_UpdateTimers()
		this.timer = 0
	end
end

SLASH_TOTEMIC1 = "/totemic"
SlashCmdList["TOTEMIC"] = function()
	if TotemicFrame:IsVisible() then
		TotemicFrame:Hide()
	else
		TotemicFrame:Show()
	end
end
