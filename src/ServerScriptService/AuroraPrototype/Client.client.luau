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
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Status"
panel.Size = UDim2.fromOffset(430, 146)
panel.Position = UDim2.fromOffset(16, 16)
panel.BackgroundColor3 = Color3.fromRGB(25, 31, 38)
panel.BackgroundTransparency = 0.08
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

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
	item.TextWrapped = true
	item.Parent = panel
	return item
end

local title = label("Title", 8, 25, 19)
local stats = label("Stats", 36, 24, 15)
local quest = label("Quest", 63, 46, 16, Color3.fromRGB(252, 226, 125))
local note = label("Note", 111, 27, 13, Color3.fromRGB(196, 214, 222))
title.Text = "ILHA DA AURORA | Protótipo"
stats.Text = "Carregando..."
quest.Text = ""
note.Text = "Clique ou 1: ataque | E: converse com o instrutor"

local function render(state)
	if not state then return end
	stats.Text = ("Paladino  Nv.%d  Vida %d/%d  EXP %d/%d  Moedas %d"):format(
		state.Level, math.ceil(state.Health), state.MaxHealth, state.XP, state.XPToNext, state.Gold
	)
	quest.Text = state.Quest
	if state.ReadOnly then
		note.Text = "Sem acesso ao DataStore: progresso desta sessão não será salvo."
	elseif state.QuestId == "DONE" then
		note.Text = "Martelo raro recebido. Salve e reconecte para testar o perfil."
	else
		note.Text = "Clique ou 1: ataque | E: converse com o instrutor | Arma: " .. state.Weapon
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
