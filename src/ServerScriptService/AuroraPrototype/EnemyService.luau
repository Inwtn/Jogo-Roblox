local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Config = require(script.Parent.Config)
local QuestService = require(script.Parent.QuestService)

local EnemyService = {}
local slimes = {}
local attackTimes = {}

local function rootOf(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root then return root, humanoid end
	return nil, nil
end

local function inSafeZone(position)
	return (Vector3.new(position.X, 0, position.Z) - Vector3.new(Config.TestArenaCenter.X, 0, Config.TestArenaCenter.Z)).Magnitude < Config.SafeRadius
end

local function createSlime(folder, position, index)
	local model = Instance.new("Model")
	model.Name = "Slime" .. index
	model:SetAttribute("EnemyType", "slime")
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(5, 4, 5)
	body.Anchored = true
	body.CanCollide = false
	body.Material = Enum.Material.Neon
	body.Color = Color3.fromRGB(78, 205, 103)
	body.Position = position
	body.Parent = model
	local board = Instance.new("BillboardGui")
	board.Name = "Nameplate"
	board.Adornee = body
	board.AlwaysOnTop = true
	board.MaxDistance = 75
	board.Size = UDim2.fromOffset(125, 35)
	board.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
	board.Parent = body
	local text = Instance.new("TextLabel")
	text.Name = "HealthText"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundColor3 = Color3.fromRGB(20, 40, 25)
	text.BackgroundTransparency = 0.05
	text.Font = Enum.Font.GothamBold
	text.TextColor3 = Color3.fromRGB(172, 255, 176)
	text.TextSize = 14
	text.Text = ("SLIME VERDE  %d/%d"):format(Config.Slime.MaxHealth, Config.Slime.MaxHealth)
	text.Parent = board
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = text
	model.PrimaryPart = body
	model.Parent = folder
	model:SetAttribute("Health", Config.Slime.MaxHealth)
	return { Model = model, Body = body, Nameplate = board, HealthText = text, Home = position, Health = Config.Slime.MaxHealth, Dead = false, Hits = {}, LastAttack = 0 }
end

local function updateHealth(slime)
	slime.HealthText.Text = ("SLIME VERDE  %d/%d"):format(slime.Health, Config.Slime.MaxHealth)
end

function EnemyService.Start(folder, positions)
	for index, position in positions do
		table.insert(slimes, createSlime(folder, position, index))
	end
	local accumulator = 0
	RunService.Heartbeat:Connect(function(dt)
		accumulator += dt
		if accumulator < 0.1 then return end
		local step = math.min(accumulator, 0.2)
		accumulator = 0
		for _, slime in slimes do
			if slime.Dead then continue end
			local position = slime.Body.Position
			local nearestPlayer, nearestRoot, nearestHumanoid, nearestDistance
			for _, player in Players:GetPlayers() do
				local root, humanoid = rootOf(player)
				if root and not inSafeZone(root.Position) then
					local distance = (root.Position - position).Magnitude
					if distance <= Config.Slime.DetectRange and (not nearestDistance or distance < nearestDistance) then
						nearestPlayer, nearestRoot, nearestHumanoid, nearestDistance = player, root, humanoid, distance
					end
				end
			end
			local destination = slime.Home
			if nearestPlayer and (position - slime.Home).Magnitude <= Config.Slime.LeashRange then
				destination = Vector3.new(nearestRoot.Position.X, slime.Home.Y, nearestRoot.Position.Z)
				if nearestDistance <= Config.Slime.AttackRange and os.clock() - slime.LastAttack >= Config.Slime.AttackCooldown then
					slime.LastAttack = os.clock()
					nearestHumanoid:TakeDamage(Config.Slime.Damage)
				end
			else
				slime.Health = Config.Slime.MaxHealth
				slime.Model:SetAttribute("Health", slime.Health)
				updateHealth(slime)
				slime.Hits = {}
			end
			local offset = destination - position
			if offset.Magnitude > 0.2 then
				local nextPosition = position + offset.Unit * math.min(offset.Magnitude, Config.Slime.Speed * step)
				slime.Body.Position = nextPosition
			end
		end
	end)
end

function EnemyService.Attack(player, target, dummy)
	local root = rootOf(player)
	if not root then return end
	local now = os.clock()
	if now - (attackTimes[player] or 0) < Config.Paladin.AttackCooldown then return end
	if typeof(target) ~= "Instance" then return end
	if target == dummy then
		if (root.Position - dummy.Position).Magnitude > Config.Paladin.AttackRange then return end
		attackTimes[player] = now
		QuestService.HitDummy(player)
		return
	end
	for _, slime in slimes do
		if target == slime.Model or target:IsDescendantOf(slime.Model) then
			if slime.Dead or (root.Position - slime.Body.Position).Magnitude > Config.Paladin.AttackRange then return end
			attackTimes[player] = now
			slime.Health = math.max(0, slime.Health - Config.Paladin.AttackDamage)
			slime.Model:SetAttribute("Health", slime.Health)
			updateHealth(slime)
			slime.Hits[player] = now
			if slime.Health == 0 then
				slime.Dead = true
				slime.Body.Transparency = 1
				slime.Nameplate.Enabled = false
				for contributor, hitTime in slime.Hits do
					local contributorRoot = rootOf(contributor)
					if contributor.Parent == Players and contributorRoot and now - hitTime <= 30 and (contributorRoot.Position - slime.Body.Position).Magnitude <= 60 then
						QuestService.KilledSlime(contributor)
					end
				end
				task.delay(Config.Slime.RespawnSeconds, function()
					if not slime.Model.Parent then return end
					slime.Health = Config.Slime.MaxHealth
					slime.Hits = {}
					slime.Body.Position = slime.Home
					slime.Body.Transparency = 0
					slime.Model:SetAttribute("Health", slime.Health)
					updateHealth(slime)
					slime.Nameplate.Enabled = true
					slime.Dead = false
				end)
			end
			return
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	attackTimes[player] = nil
	for _, slime in slimes do slime.Hits[player] = nil end
end)

return EnemyService
