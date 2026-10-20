local Config = require(script.Parent.Config)
local DataService = require(script.Parent.DataService)

local QuestService = {}
QuestService.Changed = Instance.new("BindableEvent")

local function addXP(data, amount)
	if data.Level >= Config.MaxLevel then
		return
	end
	data.XP += amount
	while data.Level < Config.MaxLevel and data.XP >= Config.XPToNextLevel(data.Level) do
		data.XP -= Config.XPToNextLevel(data.Level)
		data.Level += 1
	end
	if data.Level == Config.MaxLevel then
		data.XP = 0
	end
end

function QuestService.Trainer(player)
	local state = DataService.Get(player)
	if not state then return end
	local data = state.Data
	local quest = data.QuestState
	if quest.Id == "Q01" then
		if not quest.Spoke then
			quest.Spoke = true
		elseif quest.DummyHit and not data.CompletedQuests.Q01 then
			data.CompletedQuests.Q01 = true
			data.Gold += 10
			addXP(data, 40)
			data.QuestState = { Id = "Q02", Kills = 0 }
		end
	elseif quest.Id == "Q02" and quest.Kills >= 3 and not data.CompletedQuests.Q02 then
		data.CompletedQuests.Q02 = true
		data.Gold += 20
		addXP(data, 100)
		table.insert(data.Inventory.Weapons, "paladin_rare")
		data.Equipped.Weapon = "paladin_rare"
		data.QuestState = { Id = "DONE" }
	end
	QuestService.Changed:Fire(player)
end

function QuestService.HitDummy(player)
	local state = DataService.Get(player)
	if not state then return end
	local quest = state.Data.QuestState
	if quest.Id == "Q01" and quest.Spoke then
		quest.DummyHit = true
		QuestService.Changed:Fire(player)
	end
end

function QuestService.KilledSlime(player)
	local state = DataService.Get(player)
	if not state then return end
	local data = state.Data
	addXP(data, Config.Slime.XP)
	local quest = data.QuestState
	if quest.Id == "Q02" then
		quest.Kills = math.min(3, (quest.Kills or 0) + 1)
	end
	QuestService.Changed:Fire(player)
end

function QuestService.View(player)
	local state = DataService.Get(player)
	if not state then return nil end
	local data = state.Data
	local quest = data.QuestState
	local description
	if quest.Id == "Q01" then
		if not quest.Spoke then
			description = "Aproxime-se do INSTRUTOR AZUL e pressione E."
		elseif not quest.DummyHit then
			description = "Chegue perto do BONECO DE MADEIRA e clique nele para atacar."
		else
			description = "Volte ao INSTRUTOR AZUL e pressione E."
		end
	elseif quest.Id == "Q02" then
		if quest.Kills >= 3 then
			description = "Volte ao INSTRUTOR AZUL e pressione E para receber o martelo."
		else
			description = ("Derrote os SLIMES VERDES no campo: %d/3."):format(quest.Kills or 0)
		end
	else
		description = "Treino concluído! Martelo raro recebido."
	end
	return {
		ClassId = data.ClassId,
		Level = data.Level,
		XP = data.XP,
		XPToNext = data.Level < Config.MaxLevel and Config.XPToNextLevel(data.Level) or 0,
		Gold = data.Gold,
		Quest = description,
		QuestId = quest.Id,
		Weapon = data.Equipped.Weapon,
		ReadOnly = state.ReadOnly,
	}
end

return QuestService
