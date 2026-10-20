local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local Config = require(script.Parent.Config)
local storeAvailable, storeOrError = pcall(function()
	return DataStoreService:GetDataStore(Config.DataStoreName)
end)
local store = storeAvailable and storeOrError or nil
if not store then
	warn("Aurora: DataStore indisponível; esta sessão não será salva: " .. tostring(storeOrError))
end
local sessionId = HttpService:GenerateGUID(false)
local profiles = {}
local saving = {}

local DataService = {}

local function fresh(userId)
	return {
		UserId = userId,
		SchemaVersion = Config.SchemaVersion,
		ClassId = "paladin",
		Level = 1,
		XP = 0,
		Gold = 0,
		Inventory = { Weapons = { "paladin_basic" }, Armor = { "paladin_basic_armor" }, Potions = 0 },
		Equipped = { Weapon = "paladin_basic", Armor = "paladin_basic_armor" },
		QuestState = { Id = "Q01", Spoke = false, DummyHit = false, Kills = 0 },
		CompletedQuests = {},
		UnlockedMounts = {},
		StarterGearGranted = true,
	}
end

local function cloneData(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for key, child in pairs(value) do
		copy[key] = cloneData(child)
	end
	return copy
end

local function safeProfile(raw, userId)
	local base = fresh(userId)
	if type(raw) ~= "table" then
		return base
	end
	base.ClassId = raw.ClassId == "paladin" and raw.ClassId or base.ClassId
	base.Level = type(raw.Level) == "number" and math.clamp(math.floor(raw.Level), 1, Config.MaxLevel) or base.Level
	base.XP = type(raw.XP) == "number" and math.max(0, math.floor(raw.XP)) or base.XP
	if base.Level == Config.MaxLevel then base.XP = 0 end
	base.Gold = type(raw.Gold) == "number" and math.max(0, math.floor(raw.Gold)) or base.Gold
	base.Inventory = type(raw.Inventory) == "table" and raw.Inventory or base.Inventory
	base.Equipped = type(raw.Equipped) == "table" and raw.Equipped or base.Equipped
	base.QuestState = type(raw.QuestState) == "table" and raw.QuestState or base.QuestState
	base.CompletedQuests = type(raw.CompletedQuests) == "table" and raw.CompletedQuests or base.CompletedQuests
	base.UnlockedMounts = type(raw.UnlockedMounts) == "table" and raw.UnlockedMounts or base.UnlockedMounts
	base.StarterGearGranted = raw.StarterGearGranted == true
	if type(base.Inventory.Weapons) ~= "table" then base.Inventory.Weapons = { "paladin_basic" } end
	if type(base.Inventory.Armor) ~= "table" then base.Inventory.Armor = { "paladin_basic_armor" } end
	if type(base.Equipped.Weapon) ~= "string" then base.Equipped.Weapon = "paladin_basic" end
	if type(base.Equipped.Armor) ~= "string" then base.Equipped.Armor = "paladin_basic_armor" end
	if type(base.QuestState.Id) ~= "string" then base.QuestState = { Id = "Q01", Spoke = false, DummyHit = false, Kills = 0 } end
	return base
end

function DataService.Load(player)
	if not store then
		profiles[player] = { Data = fresh(player.UserId), ReadOnly = true }
		return profiles[player]
	end
	local key = "User_" .. player.UserId
	local lockConflict = false
	local incompatible = false
	local success, stored
	for attempt = 1, 3 do
		lockConflict = false
		incompatible = false
		success, stored = pcall(function()
			return store:UpdateAsync(key, function(current)
				lockConflict = false
				incompatible = false
				if type(current) == "table" then
					if current.SchemaVersion ~= Config.SchemaVersion or current.UserId ~= player.UserId then
						incompatible = true
						return nil
					end
					local lock = current.SessionLock
					if type(lock) == "table" and lock.Id ~= sessionId and type(lock.ExpiresAt) == "number" and lock.ExpiresAt > os.time() then
						lockConflict = true
						return nil
					end
				end
				local nextData = safeProfile(current, player.UserId)
				nextData.SessionLock = { Id = sessionId, ExpiresAt = os.time() + Config.LockSeconds }
				return nextData
			end)
		end)
		if success then break end
		if attempt < 3 then task.wait(attempt) end
	end

	if success and (lockConflict or incompatible) then
		return nil, incompatible and "Perfil de uma versão mais recente." or "Perfil aberto em outro servidor. Tente novamente em instantes."
	end
	if success and type(stored) == "table" then
		profiles[player] = { Data = safeProfile(stored, player.UserId), ReadOnly = false }
	else
		warn("Aurora: falha ao carregar perfil de " .. player.UserId .. ": " .. tostring(stored))
		profiles[player] = { Data = fresh(player.UserId), ReadOnly = true }
	end
	return profiles[player]
end

function DataService.Get(player)
	return profiles[player]
end

function DataService.Save(player, release)
	local state = profiles[player]
	if not state or state.ReadOnly or saving[player] then
		return false
	end
	saving[player] = true
	local snapshot = cloneData(state.Data)
	local key = "User_" .. player.UserId
	local owned = false
	local success, err
	for attempt = 1, 3 do
		owned = false
		success, err = pcall(function()
			store:UpdateAsync(key, function(current)
				owned = false
				if type(current) ~= "table" or type(current.SessionLock) ~= "table" or current.SessionLock.Id ~= sessionId then
					return nil
				end
				owned = true
				local nextData = cloneData(snapshot)
				if not release then
					nextData.SessionLock = { Id = sessionId, ExpiresAt = os.time() + Config.LockSeconds }
				end
				return nextData
			end)
		end)
		if success then break end
		if attempt < 3 then task.wait(attempt) end
	end
	saving[player] = nil
	if not success or not owned then
		if success and not owned then state.ReadOnly = true end
		warn("Aurora: falha ao salvar perfil de " .. player.UserId .. ": " .. tostring(err))
		return false
	end
	return true
end

function DataService.Release(player)
	while saving[player] do task.wait(0.1) end
	DataService.Save(player, true)
	profiles[player] = nil
end

task.spawn(function()
	while true do
		task.wait(Config.SaveInterval)
		for player in pairs(profiles) do
			if player.Parent == Players then
				DataService.Save(player, false)
			end
		end
	end
end)

game:BindToClose(function()
	for player in pairs(profiles) do
		DataService.Save(player, true)
	end
end)

return DataService
