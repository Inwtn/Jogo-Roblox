local Config = require(script.Parent.Config)

local TestArena = {}

local function part(parent, name, size, position, color, material)
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.Size = size
	item.Position = position
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Parent = parent
	return item
end

local function nameplate(target, name, hint, color)
	local board = Instance.new("BillboardGui")
	board.Name = "Nameplate"
	board.Adornee = target
	board.AlwaysOnTop = true
	board.MaxDistance = 75
	board.Size = UDim2.fromOffset(195, 58)
	board.StudsOffsetWorldSpace = Vector3.new(0, target.Size.Y / 2 + 2.5, 0)
	board.Parent = target

	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(20, 27, 34)
	background.BackgroundTransparency = 0.05
	background.Parent = board
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = background

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(7, 5)
	title.Size = UDim2.new(1, -14, 0, 24)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 17
	title.TextColor3 = color
	title.Text = name
	title.Parent = background

	local instruction = Instance.new("TextLabel")
	instruction.BackgroundTransparency = 1
	instruction.Position = UDim2.fromOffset(7, 30)
	instruction.Size = UDim2.new(1, -14, 0, 22)
	instruction.Font = Enum.Font.Gotham
	instruction.TextSize = 14
	instruction.TextColor3 = Color3.fromRGB(240, 245, 248)
	instruction.Text = hint
	instruction.Parent = background
end

function TestArena.Create()
	local old = workspace:FindFirstChild("AuroraTestArena")
	if old then error("AuroraTestArena já existe. Remova a cópia duplicada de AuroraPrototype.") end
	local center = Config.TestArenaCenter
	local arena = Instance.new("Folder")
	arena.Name = "AuroraTestArena"
	arena.Parent = workspace

	part(arena, "Solo", Vector3.new(150, 2, 100), center + Vector3.new(20, -4, 0), Color3.fromRGB(91, 150, 87), Enum.Material.Grass)
	part(arena, "VilaSegura", Vector3.new(28, 0.4, 28), center + Vector3.new(0, -2.8, 0), Color3.fromRGB(213, 193, 136), Enum.Material.Sand)
	part(arena, "Caminho", Vector3.new(72, 0.3, 8), center + Vector3.new(36, -2.7, 0), Color3.fromRGB(188, 171, 139), Enum.Material.Sand)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "AuroraSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = center + Vector3.new(-5, -2.2, 0)
	spawn.Color = Color3.fromRGB(240, 215, 122)
	spawn.Parent = arena

	local trainer = part(arena, "Instrutor", Vector3.new(3, 7, 3), center + Vector3.new(-2, 1, -9), Color3.fromRGB(47, 92, 154))
	nameplate(trainer, "INSTRUTOR AZUL", "Pressione E para conversar", Color3.fromRGB(133, 198, 255))
	local trainerPrompt = Instance.new("ProximityPrompt")
	trainerPrompt.Name = "Conversar"
	trainerPrompt.ActionText = "Conversar"
	trainerPrompt.ObjectText = "Instrutor da Aurora"
	trainerPrompt.MaxActivationDistance = 10
	trainerPrompt.HoldDuration = 0
	trainerPrompt.Parent = trainer

	local dummy = part(arena, "BonecoDeTreino", Vector3.new(3, 6, 2), center + Vector3.new(7, 0, -10), Color3.fromRGB(140, 93, 51), Enum.Material.Wood)
	nameplate(dummy, "BONECO DE MADEIRA", "Chegue perto e clique nele", Color3.fromRGB(255, 209, 139))
	local sign = part(arena, "PlacaVila", Vector3.new(1, 7, 6), center + Vector3.new(14, 1, 12), Color3.fromRGB(130, 91, 63), Enum.Material.Wood)
	sign.CanCollide = false

	local enemies = Instance.new("Folder")
	enemies.Name = "AuroraEnemies"
	enemies.Parent = workspace

	return {
		Arena = arena,
		Spawn = spawn,
		TrainerPrompt = trainerPrompt,
		Dummy = dummy,
		Enemies = enemies,
		SlimePositions = {
			center + Vector3.new(38, 0, -11),
			center + Vector3.new(48, 0, 10),
			center + Vector3.new(59, 0, -5),
		},
	}
end

return TestArena
