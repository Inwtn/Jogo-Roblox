local ServerScriptService = game:GetService("ServerScriptService")
if script.Parent.Parent ~= ServerScriptService then
	script.Parent.Parent = ServerScriptService
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(script.Parent.Config)
local DataService = require(script.Parent.DataService)
local QuestService = require(script.Parent.QuestService)
local TestArena = require(script.Parent.TestArena)
local EnemyService = require(script.Parent.EnemyService)

local arena = TestArena.Create()
EnemyService.Start(arena.Enemies, arena.SlimePositions)

local remotes = ReplicatedStorage:FindFirstChild("AuroraRemotes") or Instance.new("Folder")
remotes.Name = "AuroraRemotes"
remotes.Parent = ReplicatedStorage

local attack = remotes:FindFirstChild("Attack") or Instance.new("RemoteEvent")
attack.Name = "Attack"
attack.Parent = remotes
local stateChanged = remotes:FindFirstChild("StateChanged") or Instance.new("RemoteEvent")
stateChanged.Name = "StateChanged"
stateChanged.Parent = remotes
local getState = remotes:FindFirstChild("GetState") or Instance.new("RemoteFunction")
getState.Name = "GetState"
getState.Parent = remotes

local function view(player)
	local state = QuestService.View(player)
	if not state then return nil end
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	state.Health = humanoid and humanoid.Health or Config.Paladin.MaxHealth
	state.MaxHealth = humanoid and humanoid.MaxHealth or Config.Paladin.MaxHealth
	return state
end

local function send(player)
	local current = view(player)
	if current then stateChanged:FireClient(player, current) end
end

getState.OnServerInvoke = function(player)
	return view(player)
end

attack.OnServerEvent:Connect(function(player, target)
	local state = DataService.Get(player)
	if not state or state.Data.ClassId ~= "paladin" then return end
	EnemyService.Attack(player, target, arena.Dummy)
end)

arena.TrainerPrompt.Triggered:Connect(function(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - arena.TrainerPrompt.Parent.Position).Magnitude > 12 then return end
	QuestService.Trainer(player)
end)

QuestService.Changed.Event:Connect(send)

local function onCharacter(player, character)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not root or not humanoid then return end
	humanoid.MaxHealth = Config.Paladin.MaxHealth
	humanoid.Health = humanoid.MaxHealth
	character:PivotTo(CFrame.new(arena.Spawn.Position + Vector3.new(0, 5, 0)))
	humanoid.HealthChanged:Connect(function() send(player) end)
	send(player)
end

local function onPlayer(player)
	local state, problem = DataService.Load(player)
	if not state then
		player:Kick(problem or "Não foi possível abrir o perfil. Tente novamente.")
		return
	end
	local client = script.Parent:FindFirstChild("Client")
	local playerGui = player:WaitForChild("PlayerGui", 10)
	if client and playerGui and not playerGui:FindFirstChild("AuroraClientHost") then
		local host = Instance.new("ScreenGui")
		host.Name = "AuroraClientHost"
		host.ResetOnSpawn = false
		local copy = client:Clone()
		copy.Name = "AuroraClient"
		copy.Parent = host
		host.Parent = playerGui
	end
	player.CharacterAdded:Connect(function(character) onCharacter(player, character) end)
	if player.Character then onCharacter(player, player.Character) end
	send(player)
end

Players.PlayerAdded:Connect(onPlayer)
Players.PlayerRemoving:Connect(function(player)
	DataService.Release(player)
end)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
