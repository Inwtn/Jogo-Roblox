local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local remotes = ReplicatedStorage:WaitForChild("AuroraRemotes")
local attack = remotes:WaitForChild("Attack")
local stateChanged = remotes:WaitForChild("StateChanged")
local getState = remotes:WaitForChild("GetState")

local navy = Color3.fromRGB(18, 34, 53)
local gold = Color3.fromRGB(230, 179, 76)
local cream = Color3.fromRGB(251, 242, 218)
local muted = Color3.fromRGB(175, 194, 206)

local gui = Instance.new("ScreenGui")
gui.Name = "AuroraHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)
pcall(function() StarterGui:SetCore("ChatActive", false) end)

local function panel(name, size, position, anchor, parent, color)
	local item = Instance.new("Frame")
	item.Name = name
	item.Size = size
	item.Position = position
	item.AnchorPoint = anchor
	item.BackgroundColor3 = color or navy
	item.BackgroundTransparency = 0.04
	item.Parent = parent or gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = item
	local stroke = Instance.new("UIStroke")
	stroke.Color = gold
	stroke.Thickness = 1.5
	stroke.Transparency = 0.12
	stroke.Parent = item
	return item
end

local function label(parent, name, text, position, size, fontSize, color, bold)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.BackgroundTransparency = 1
	item.Position = position
	item.Size = size
	item.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	item.Text = text
	item.TextColor3 = color or cream
	item.TextSize = fontSize
	item.TextWrapped = true
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function bar(parent, name, y, fillColor)
	local track = Instance.new("Frame")
	track.Name = name
	track.Position = UDim2.fromOffset(12, y)
	track.Size = UDim2.new(1, -24, 0, 11)
	track.BackgroundColor3 = Color3.fromRGB(7, 16, 25)
	track.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = track
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = fillColor
	fill.Parent = track
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = fill
	return fill
end

local location = panel("Location", UDim2.fromOffset(194, 48), UDim2.new(0.5, 0, 0, 12), Vector2.new(0.5, 0))
local locationTitle = label(location, "Title", "Prado da Aurora", UDim2.fromOffset(8, 5), UDim2.new(1, -16, 0, 23), 17, gold, true)
locationTitle.TextXAlignment = Enum.TextXAlignment.Center
local locationLevel = label(location, "Level", "Área de nível 1–3", UDim2.fromOffset(8, 27), UDim2.new(1, -16, 0, 17), 12, cream)
locationLevel.TextXAlignment = Enum.TextXAlignment.Center

local map = panel("Minimap", UDim2.fromOffset(138, 138), UDim2.new(1, -15, 0, 12), Vector2.new(1, 0), gui, Color3.fromRGB(54, 112, 69))
map.ClipsDescendants = true
map:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(1, 0)
local mapGradient = Instance.new("UIGradient")
mapGradient.Color = ColorSequence.new(Color3.fromRGB(49, 110, 65), Color3.fromRGB(103, 151, 89))
mapGradient.Rotation = 75
mapGradient.Parent = map

local function mapDot(name, x, y, diameter, color)
	local dot = Instance.new("Frame")
	dot.Name = name
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.fromScale(x, y)
	dot.Size = UDim2.fromOffset(diameter, diameter)
	dot.BackgroundColor3 = color
	dot.Parent = map
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(1, 0)
	round.Parent = dot
	return dot
end

local road = Instance.new("Frame")
road.Name = "Estrada"
road.AnchorPoint = Vector2.new(0.5, 0.5)
road.Position = UDim2.fromScale(0.5, 0.47)
road.Size = UDim2.fromOffset(15, 128)
road.BackgroundColor3 = Color3.fromRGB(213, 184, 127)
road.Rotation = 3
road.Parent = map
mapDot("Vila", 0.44, 0.83, 16, Color3.fromRGB(244, 181, 84))
mapDot("Caverna", 0.5, 0.09, 17, Color3.fromRGB(62, 94, 126))
mapDot("Slime1", 0.48, 0.54, 7, Color3.fromRGB(100, 235, 98))
mapDot("Slime2", 0.54, 0.46, 7, Color3.fromRGB(100, 235, 98))
mapDot("Slime3", 0.47, 0.37, 7, Color3.fromRGB(100, 235, 98))
local playerDot = mapDot("Jogador", 0.47, 0.75, 11, Color3.fromRGB(91, 204, 255))
local playerStroke = Instance.new("UIStroke")
playerStroke.Color = Color3.fromRGB(255, 255, 255)
playerStroke.Thickness = 2
playerStroke.Parent = playerDot
local questPanel = panel("Missions", UDim2.fromOffset(234, 158), UDim2.new(1, -15, 0, 177), Vector2.new(1, 0))
local questHeading = label(questPanel, "Heading", "MISSÕES", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 25), 16, gold, true)
local questTitle = label(questPanel, "QuestTitle", "PRIMEIROS PASSOS", UDim2.fromOffset(12, 35), UDim2.new(1, -24, 0, 19), 12, cream, true)
local quest = label(questPanel, "Quest", "Aguarde a missão carregar...", UDim2.fromOffset(12, 57), UDim2.new(1, -24, 0, 59), 15, cream)
local reward = label(questPanel, "Reward", "Recompensa: EXP e moedas", UDim2.fromOffset(12, 116), UDim2.new(1, -24, 0, 18), 11, gold)
local saveNote = label(questPanel, "SaveNote", "", UDim2.fromOffset(12, 134), UDim2.new(1, -24, 0, 19), 10, muted)

local status = panel("Status", UDim2.fromOffset(238, 124), UDim2.new(0, 15, 0, 64), Vector2.new(0, 0))
label(status, "Heading", player.DisplayName, UDim2.fromOffset(12, 5), UDim2.new(1, -24, 0, 24), 17, gold, true)
local classLine = label(status, "Class", "Paladino  •  Nv.1", UDim2.fromOffset(12, 29), UDim2.new(1, -24, 0, 18), 13, cream)
local healthText = label(status, "Health", "Vida 100/100", UDim2.fromOffset(12, 48), UDim2.new(1, -24, 0, 16), 12, cream)
local healthFill = bar(status, "HealthBar", 64, Color3.fromRGB(62, 206, 83))
local xpText = label(status, "XP", "EXP 0/80", UDim2.fromOffset(12, 79), UDim2.new(1, -24, 0, 16), 12, cream)
local xpFill = bar(status, "XPBar", 95, Color3.fromRGB(55, 154, 239))
local weaponText = label(status, "Weapon", "Martelo de treino", UDim2.fromOffset(12, 107), UDim2.new(1, -24, 0, 15), 10, muted)

local goldPanel = panel("Gold", UDim2.fromOffset(132, 29), UDim2.new(0, 15, 1, -11), Vector2.new(0, 1))
local goldText = label(goldPanel, "Amount", "0 moedas", UDim2.fromOffset(11, 3), UDim2.new(1, -22, 0, 22), 13, gold, true)

local hotbar = panel("Hotbar", UDim2.fromOffset(278, 64), UDim2.new(0.5, 0, 1, -14), Vector2.new(0.5, 1))
for slot = 1, 5 do
	local tile = panel("Slot" .. slot, UDim2.fromOffset(47, 48), UDim2.fromOffset(10 + (slot - 1) * 53, 8), Vector2.new(0, 0), hotbar,
		slot == 1 and Color3.fromRGB(76, 67, 44) or Color3.fromRGB(30, 45, 62))
	local symbol = slot == 1 and "ATAQUE" or "EM BREVE"
	local text = label(tile, "Action", slot .. "\n" .. symbol, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), slot == 1 and 11 or 9,
		slot == 1 and gold or muted, slot == 1)
	text.TextXAlignment = Enum.TextXAlignment.Center
end

local function render(state)
	if not state then return end
	classLine.Text = ("Paladino  •  Nv.%d"):format(state.Level)
	healthText.Text = ("Vida  %d/%d"):format(math.ceil(state.Health), state.MaxHealth)
	healthFill.Size = UDim2.fromScale(math.clamp(state.Health / math.max(1, state.MaxHealth), 0, 1), 1)
	xpText.Text = ("EXP  %d/%d"):format(state.XP, state.XPToNext)
	xpFill.Size = UDim2.fromScale(state.XPToNext > 0 and math.clamp(state.XP / state.XPToNext, 0, 1) or 1, 1)
	goldText.Text = ("●  %d moedas"):format(state.Gold)
	weaponText.Text = state.Weapon == "paladin_rare" and "Martelo raro da Aurora" or "Martelo de treino"
	questTitle.Text = state.QuestId == "Q01" and "Q01  •  TREINAMENTO" or (state.QuestId == "Q02" and "Q02  •  PRIMEIROS PASSOS" or "CONCLUÍDA")
	quest.Text = state.Quest
	reward.Text = state.QuestId == "Q01" and "Recompensa: 40 EXP + 10 moedas" or (state.QuestId == "Q02" and "Recompensa: martelo raro" or "Treino completo")
	saveNote.Text = state.ReadOnly and "Teste local: progresso não será salvo" or "Progresso salvo automaticamente"
end

stateChanged.OnClientEvent:Connect(render)
local ok, initial = pcall(function() return getState:InvokeServer() end)
if ok then render(initial) end

local function requestAttack()
	local target = mouse.Target
	if target then attack:FireServer(target) end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or UserInputService:GetFocusedTextBox() then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.One then
		requestAttack()
	end
end)

local mapElapsed = 0
RunService.Heartbeat:Connect(function(dt)
	mapElapsed += dt
	if mapElapsed < 0.15 then return end
	mapElapsed = 0
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local arena = workspace:FindFirstChild("AuroraWorld")
	local origin = arena and arena:GetAttribute("Origin")
	if not root or not origin then return end
	local centerX = origin.X
	local centerZ = origin.Z
	playerDot.Position = UDim2.fromScale(
		math.clamp(0.5 + (root.Position.X - centerX) / 200, 0.07, 0.93),
		math.clamp(0.8 + (root.Position.Z - centerZ) / 235, 0.07, 0.93)
	)
end)
