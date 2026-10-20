local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local remotes = ReplicatedStorage:WaitForChild("AuroraRemotes")
local attack = remotes:WaitForChild("Attack")
local stateChanged = remotes:WaitForChild("StateChanged")
local getState = remotes:WaitForChild("GetState")

local gui = Instance.new("ScreenGui")
gui.Name = "AuroraHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Status"
panel.AnchorPoint = Vector2.new(0, 1)
panel.Size = UDim2.fromOffset(390, 182)
panel.Position = UDim2.new(0, 16, 1, -16)
panel.BackgroundColor3 = Color3.fromRGB(20, 27, 34)
panel.BackgroundTransparency = 0.02
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel
local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(108, 143, 167)
outline.Transparency = 0.35
outline.Thickness = 1
outline.Parent = panel

local function label(name, y, height, size, color)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.BackgroundTransparency = 1
	item.Position = UDim2.fromOffset(12, y)
	item.Size = UDim2.new(1, -24, 0, height)
	item.Font = Enum.Font.Gotham
	item.TextColor3 = color or Color3.fromRGB(245, 245, 245)
	item.TextSize = size
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.TextWrapped = true
	item.Parent = panel
	return item
end

local title = label("Title", 10, 25, 19)
title.Font = Enum.Font.GothamBold
local stats = label("Stats", 38, 22, 14)
local heading = label("QuestHeading", 66, 21, 13, Color3.fromRGB(158, 203, 222))
heading.Font = Enum.Font.GothamBold
local quest = label("Quest", 88, 48, 17, Color3.fromRGB(255, 229, 144))
quest.Font = Enum.Font.GothamBold
local note = label("Note", 143, 30, 13, Color3.fromRGB(196, 214, 222))
title.Text = "ILHA DA AURORA"
stats.Text = "Carregando..."
heading.Text = "PRÓXIMO PASSO"
quest.Text = "Aguarde a missão carregar..."
note.Text = "Clique: atacar  •  E: conversar"

local function render(state)
	if not state then return end
	stats.Text = ("Paladino Nv.%d  |  Vida %d/%d  |  EXP %d/%d  |  %d moedas"):format(
		state.Level, math.ceil(state.Health), state.MaxHealth, state.XP, state.XPToNext, state.Gold
	)
	quest.Text = state.Quest
	if state.ReadOnly then
		note.Text = "Teste local: progresso não será salvo. Clique: atacar  •  E: conversar"
	elseif state.QuestId == "DONE" then
		note.Text = "Martelo raro equipado. Treino concluído!"
	else
		note.Text = "Clique ou tecla 1: atacar  •  E: conversar"
	end
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
