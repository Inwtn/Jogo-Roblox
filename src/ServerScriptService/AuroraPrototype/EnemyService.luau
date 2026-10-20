local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Config = require(script.Parent.Config)
local QuestService = require(script.Parent.QuestService)
local PaladinVisual = require(script.Parent.PaladinVisual)

local EnemyService = {}
local slimes = {}
local attackTimes = {}
local groundFilter = RaycastParams.new()
groundFilter.FilterType = Enum.RaycastFilterType.Include
groundFilter.FilterDescendantsInstances = { workspace.Terrain }

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
	body.Size = Vector3.new(4.6, 3.5, 4.3)
	body.Anchored = true
	body.CanCollide = false
	body.Material = Enum.Material.SmoothPlastic
	body.Color = Color3.fromRGB(118, 201, 73)
	body.Reflectance = 0.08
	body.Position = position
	body.Parent = model
	local eyes = {}
	for _, side in { -1, 1 } do
		local eye = Instance.new("Part")
		eye.Name = "Olho"
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.new(0.5, 0.7, 0.35)
		eye.Anchored = true
		eye.CanCollide = false
		eye.Color = Color3.fromRGB(19, 44, 28)
		eye.Position = position + Vector3.new(side * 0.73, 0.15, 1.94)
		eye.Parent = model
		table.insert(eyes, eye)
	end
	for index, data in {
		{ "Boca", Vector3.new(0.45,0.16,0.18), Vector3.new(0,-0.45,2.05), Color3.fromRGB(45,84,34) },
		{ "Brilho", Vector3.new(0.65,0.28,0.12), Vector3.new(-0.95,0.95,1.65), Color3.fromRGB(215,245,169) },
		{ "Broto", Vector3.new(0.45,1.05,0.65), Vector3.new(0.2,1.85,0), Color3.fromRGB(72,142,45) },
	} do
		local feature = Instance.new("Part")
		feature.Name = data[1]
		feature.Shape = Enum.PartType.Ball
		feature.Size = data[2]
		feature.Position = position + data[3]
		feature.Color = data[4]
		feature.Anchored = true
		feature.CanCollide = false
		feature.Parent = model
		table.insert(eyes, feature)
	end
	local board = Instance.new("BillboardGui")
	board.Name = "Nameplate"
	board.Adornee = body
	board.AlwaysOnTop = true
	board.MaxDistance = 34
	board.Size = UDim2.fromOffset(125, 35)
	board.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
	board.Parent = body
	local text = Instance.new("TextLabel")
	text.Name = "HealthText"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundColor3 = Color3.fromRGB(20, 40, 25)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextColor3 = Color3.fromRGB(172, 255, 176)
	text.TextSize = 14
	text.TextStrokeTransparency = 0.3
	text.Text = ("Slime · Nv.1  %d/%d"):format(Config.Slime.MaxHealth, Config.Slime.MaxHealth)
	text.Parent = board
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = text
	model.PrimaryPart = body
	model.Parent = folder
	model:SetAttribute("Health", Config.Slime.MaxHealth)
	return { Model = model, Body = body, Eyes = eyes, Nameplate = board, HealthText = text, Home = position, Health = Config.Slime.MaxHealth, Dead = false, Hits = {}, LastAttack = 0, Phase = index*2, Heading = 0 }
end

local function updateHealth(slime)
	slime.HealthText.Text = ("Slime · Nv.1  %d/%d"):format(slime.Health, Config.Slime.MaxHealth)
end

local function moveSlime(slime, position)
	local delta = position - slime.Body.Position
	if Vector3.new(delta.X,0,delta.Z).Magnitude > 0.05 then
		slime.Heading = math.atan2(delta.X,delta.Z)
	end
	local hit = workspace:Raycast(Vector3.new(position.X,100,position.Z),Vector3.new(0,-160,0),groundFilter)
	local floor = hit and hit.Position.Y or (slime.Home.Y - 2)
	local bounce = math.abs(math.sin(os.clock()*3.8 + slime.Phase))
	local pivot = CFrame.new(position.X,floor+1.75+bounce*0.45,position.Z)*CFrame.Angles(0,slime.Heading,0)
	slime.Model:PivotTo(pivot)
	slime.Body.Size = Vector3.new(4.6+(1-bounce)*0.2,3.35+bounce*0.3,4.3+(1-bounce)*0.2)
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
				moveSlime(slime, nextPosition)
			else
				moveSlime(slime, position)
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
	if target == dummy or target:IsDescendantOf(dummy.Parent) then
		if (root.Position - dummy.Position).Magnitude > Config.Paladin.AttackRange then return end
		attackTimes[player] = now
		PaladinVisual.Swing(player.Character)
		PaladinVisual.Hit(dummy)
		QuestService.HitDummy(player)
		return
	end
	for _, slime in slimes do
		if target == slime.Model or target:IsDescendantOf(slime.Model) then
			if slime.Dead or (root.Position - slime.Body.Position).Magnitude > Config.Paladin.AttackRange then return end
			attackTimes[player] = now
			PaladinVisual.Swing(player.Character)
			PaladinVisual.Hit(slime.Body, Config.Paladin.AttackDamage)
			slime.Health = math.max(0, slime.Health - Config.Paladin.AttackDamage)
			slime.Model:SetAttribute("Health", slime.Health)
			updateHealth(slime)
			slime.Hits[player] = now
			if slime.Health == 0 then
				slime.Dead = true
				slime.Body.Transparency = 1
				for _, eye in slime.Eyes do eye.Transparency = 1 end
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
					moveSlime(slime, slime.Home)
					slime.Body.Transparency = 0
					for _, eye in slime.Eyes do eye.Transparency = 0 end
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
