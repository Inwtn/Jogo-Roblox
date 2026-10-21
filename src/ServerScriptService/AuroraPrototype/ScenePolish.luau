-- Detalhes adicionais da ilha. Apply é idempotente para preservar edições feitas no Studio.
local Art = require(script.Parent.Art)

local ScenePolish = {}
local V, C = Vector3.new, Color3.fromRGB
local navy, blue, gold = C(33, 64, 103), C(54, 105, 155), C(222, 175, 83)
local wood, darkWood = C(110, 72, 43), C(70, 48, 35)
local stone, paleStone = C(103, 115, 117), C(149, 159, 153)

local function crystal(parent, base, height, tilt, glow)
	local cf = CFrame.new(base) * CFrame.Angles(0, tilt, math.rad(tilt * 6))
	local shaft = Art.Part(parent, "CristalAzul", V(1.5, height, 1.5), cf * CFrame.new(0, height / 2, 0),
		C(72, 177, 211), Enum.Material.Glass)
	Art.Part(parent, "PontaDoCristal", V(1.5, 1.5, 1.5), cf * CFrame.new(0, height + 0.65, 0),
		C(107, 225, 239), Enum.Material.Neon, "Wedge")
	if glow then
		local light = Instance.new("PointLight")
		light.Color = C(78, 189, 234)
		light.Brightness = 1.5
		light.Range = 18
		light.Parent = shaft
	end
end

local function market(parent, point)
	local m = Art.Model(parent, "FeiraDaVila")
	local center = point(-6, 31)
	Art.Part(m, "Estrado", V(12, 0.5, 8), center + V(0, 0.25, 0), wood, Enum.Material.WoodPlanks, nil, true)
	for _, x in { -5.4, 5.4 } do
		for _, z in { -3.3, 3.3 } do
			Art.Beam(m, "Coluna", center + V(x, 0, z), center + V(x, 7, z), 0.48, darkWood, Enum.Material.Wood)
		end
	end
	Art.Part(m, "Toldo", V(13, 0.45, 9), center + V(0, 7, 0), navy, Enum.Material.Fabric)
	for _, x in { -5.5, -2.75, 0, 2.75, 5.5 } do
		Art.Part(m, "FaixaDourada", V(0.55, 0.08, 9.1), center + V(x, 7.26, 0), gold, Enum.Material.Fabric)
	end
	for _, z in { -4.1, 4.1 } do
		Art.Part(m, "BordaDoToldo", V(13, 0.8, 0.3), center + V(0, 6.6, z), blue, Enum.Material.Fabric)
	end
	Art.Part(m, "Balcao", V(10.5, 1.1, 1.7), center + V(0, 2, -2.6), wood, Enum.Material.WoodPlanks)
	for _, x in { -4.2, 3.8 } do
		Art.Part(m, "Caixote", V(2, 1.6, 2), center + V(x, 1.1, 1.7), darkWood, Enum.Material.WoodPlanks)
	end
	for i = 1, 8 do
		local x = -3.5 + (i - 1) * 1.05
		local color = i % 3 == 0 and C(231, 180, 66) or C(188, 74, 64)
		Art.Part(m, "Fruta", V(0.65, 0.65, 0.65), center + V(x, 2.9, -2.5), color, Enum.Material.SmoothPlastic, "Ball")
	end
	Art.Lantern(m, CFrame.new(center + V(-5.4, 5.5, -3.3)))
	return m
end

local function gate(parent, point)
	local m = Art.Model(parent, "PortalDaTrilha")
	local center = point(13, -43)
	for _, side in { -1, 1 } do
		local x = side * 8
		Art.Part(m, "BaseDePedra", V(2.8, 1.4, 2.8), center + V(x, 0.7, 0), stone, Enum.Material.Cobblestone, nil, true)
		Art.Beam(m, "Pilar", center + V(x, 1.2, 0), center + V(x, 12, 0), 1.15, wood, Enum.Material.Wood, true)
		Art.Part(m, "Ponteira", V(1.8, 0.5, 1.8), center + V(x, 12.1, 0), gold, Enum.Material.Metal)
		Art.Part(m, "Estandarte", V(2.5, 4.4, 0.25), center + V(side * 6.6, 8.6, -0.15), navy, Enum.Material.Fabric)
		Art.Part(m, "FaixaDoEstandarte", V(0.35, 3.8, 0.3), center + V(side * 6.6, 8.6, -0.34), gold, Enum.Material.Fabric)
		Art.Lantern(m, CFrame.new(center + V(x, 8.7, 0)))
	end
	Art.Beam(m, "TravessaAlta", center + V(-8, 12, 0), center + V(8, 12, 0), 1.1, darkWood, Enum.Material.Wood)
	Art.Part(m, "EmblemaDoSol", V(2.4, 2.4, 0.45), center + V(0, 11.8, -0.62), gold, Enum.Material.Metal, "Ball")
	return m
end

local function waystones(parent, point)
	local m = Art.Model(parent, "MarcosDaEstrada")
	for index, z in { -78, -117, -150 } do
		local roadX = 5 + 10 * math.sin(-z / 45)
		for _, side in { -1, 1 } do
			local base = point(roadX + side * 10.5, z)
			Art.Part(m, "PedraGuia", V(2, 3.6, 2), base + V(0, 1.8, 0), stone, Enum.Material.Slate, nil, true)
			Art.Part(m, "Moldura", V(2.3, 0.35, 2.3), base + V(0, 3.5, 0), paleStone, Enum.Material.Cobblestone)
			Art.Part(m, "SeloDourado", V(1, 1, 0.15), base + V(0, 2.1, -1.1), gold, Enum.Material.Metal, "Ball")
			crystal(m, base + V(0, 3.6, 0), 1.4 + index * 0.2, side * 0.12, index == 3)
		end
	end
	return m
end

local function caveGlow(parent, point)
	local m = Art.Model(parent, "CristaisDaGruta")
	for index, entry in { { -4, -160 }, { 24, -160 }, { -7, -171 }, { 27, -174 } } do
		local base = point(entry[1], entry[2])
		Art.Part(m, "Pedestal", V(4.8, 1.4, 4.8), base + V(0, 0.7, 0), stone, Enum.Material.Rock, "Ball")
		crystal(m, base + V(0, 1, 0), 5 + index % 2 * 1.7, index * 0.1, true)
		crystal(m, base + V(1.5, 0.7, 0.5), 2.8, -0.15, false)
		crystal(m, base + V(-1.4, 0.6, -0.4), 3.2, 0.12, false)
	end
	return m
end

local function shrubs(parent, point)
	local m = Art.Model(parent, "ArbustosEPlantas")
	local places = {
		{ -48, 8 }, { -51, -36 }, { -42, -68 }, { -32, -92 }, { -38, -117 },
		{ 42, 27 }, { 48, -13 }, { 45, -53 }, { 40, -92 }, { 34, -135 },
		{ -13, -68 }, { 27, -76 }, { -7, -119 }, { 25, -143 },
	}
	for index, entry in places do
		local base = point(entry[1], entry[2])
		for lobe = 1, 3 do
			local angle = lobe * math.pi * 2 / 3 + index
			local offset = V(math.cos(angle) * 1.1, 1.3, math.sin(angle) * 1.1)
			Art.Part(m, "Arbusto", V(2.7, 2.3, 2.7), base + offset,
				lobe == 2 and C(70, 121, 72) or C(83, 142, 80), Enum.Material.Grass, "Ball")
		end
		for petal = 1, 3 do
			local angle = petal * math.pi * 2 / 3 + index * 0.7
			Art.Part(m, "Flor", V(0.38, 0.38, 0.38), base + V(math.cos(angle) * 1.5, 2.1, math.sin(angle) * 1.5),
				index % 2 == 0 and C(242, 206, 126) or C(173, 175, 224), Enum.Material.SmoothPlastic, "Ball")
		end
	end
	return m
end

function ScenePolish.Apply(world, point)
	local existing = world:FindFirstChild("DetalhesVisuais")
	if existing then return existing end
	local details = Art.Model(world, "DetalhesVisuais")
	details:SetAttribute("Version", 1)
	market(details, point)
	gate(details, point)
	waystones(details, point)
	caveGlow(details, point)
	shrubs(details, point)
	return details
end

return ScenePolish
