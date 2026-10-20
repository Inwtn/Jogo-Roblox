local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local V, C = Vector3.new, Color3.fromRGB
local Visual = {}
local silver, gold, blue = C(159,177,188), C(212,167,78), C(39,83,137)

local function piece(folder, name, size, color, material, anchor, offset, shape, motor)
	if not anchor then return nil end
	local p = Instance.new(shape == "Wedge" and "WedgePart" or "Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CFrame = anchor.CFrame * offset
	if shape == "Ball" then p.Shape = Enum.PartType.Ball end
	if shape == "Cylinder" then p.Shape = Enum.PartType.Cylinder end
	p.Parent = folder
	local joint = Instance.new(motor and "Motor6D" or "Weld")
	joint.Name = motor and "WeaponGrip" or "AttachmentWeld"
	joint.Part0 = anchor
	joint.Part1 = p
	joint.C0 = offset
	joint.Parent = p
	return p, joint
end

function Visual.Equip(character)
	if character:FindFirstChild("AuroraEquipment") then return end
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	local right = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	local left = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
	if not torso or not right or not left then return end
	local f = Instance.new("Folder")
	f.Name = "AuroraEquipment"
	f.Parent = character
	for i=0,3 do
		piece(f,"Capa"..i,V(2.05+i*0.13,0.85,0.12),blue,Enum.Material.Fabric,torso,
			CFrame.new(0,-0.45-i*0.67,0.63+i*0.12)*CFrame.Angles(math.rad(-9),0,0))
	end
	for _,side in {-1,1} do
		local shoulder=piece(f,"Ombreira",V(1,0.72,1.15),silver,Enum.Material.Metal,torso,CFrame.new(side*1.15,0.5,0),"Ball")
		piece(f,"BordaDourada",V(1.05,0.18,1.2),gold,Enum.Material.Metal,shoulder,CFrame.new(0,-0.17,0),"Ball")
	end
	piece(f,"EmblemaVertical",V(0.19,1.15,0.08),gold,Enum.Material.Metal,torso,CFrame.new(0,-1.1,0.96))
	piece(f,"EmblemaHorizontal",V(0.78,0.19,0.08),gold,Enum.Material.Metal,torso,CFrame.new(0,-0.83,0.91))
	local shield=piece(f,"Escudo",V(1.95,2.4,0.32),silver,Enum.Material.Metal,left,CFrame.new(-0.28,-0.55,0.35),"Ball")
	piece(f,"EscudoAzul",V(1.64,2.08,0.2),blue,Enum.Material.Metal,shield,CFrame.new(0,0,0.18),"Ball")
	piece(f,"CruzDoEscudo",V(0.18,1.35,0.14),gold,Enum.Material.Metal,shield,CFrame.new(0,0,0.31))
	piece(f,"CruzDoEscudo",V(0.83,0.18,0.14),gold,Enum.Material.Metal,shield,CFrame.new(0,0.24,0.31))
	local handle=piece(f,"CaboDoMartelo",V(2.1,0.23,0.23),C(101,68,42),Enum.Material.Wood,right,
		CFrame.new(0,-0.65,-0.15)*CFrame.Angles(0,0,math.pi/2),"Cylinder",true)
	local head=piece(f,"CabeçaDoMartelo",V(0.7,1.45,0.78),silver,Enum.Material.Metal,handle,CFrame.new(-0.87,0,0))
	for _,side in {-1,1} do
		piece(f,"FaceDoMartelo",V(0.83,0.16,0.9),gold,Enum.Material.Metal,head,CFrame.new(0,side*0.73,0))
	end
	piece(f,"Pomo",V(0.3,0.37,0.37),gold,Enum.Material.Metal,handle,CFrame.new(0.95,0,0),"Ball")
end

function Visual.Swing(character)
	local equipment = character and character:FindFirstChild("AuroraEquipment")
	local handle = equipment and equipment:FindFirstChild("CaboDoMartelo")
	local grip = handle and handle:FindFirstChild("WeaponGrip")
	if not grip then return end
	local original = CFrame.new(0,-0.65,-0.15)*CFrame.Angles(0,0,math.pi/2)
	local up = original*CFrame.Angles(0,0,math.rad(-105))
	TweenService:Create(grip,TweenInfo.new(0.09),{C0=up}):Play()
	task.delay(0.09,function()
		if not grip.Parent then return end
		TweenService:Create(grip,TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{C0=original*CFrame.Angles(0,0,0.45)}):Play()
		task.delay(0.18,function()
			if grip.Parent then TweenService:Create(grip,TweenInfo.new(0.12),{C0=original}):Play() end
		end)
	end)
end

function Visual.Hit(target, amount)
	local board = Instance.new("BillboardGui")
	board.Name = "Impacto"
	board.Size = UDim2.fromOffset(100,45)
	board.StudsOffsetWorldSpace = V(0,3,0)
	board.AlwaysOnTop = true
	board.Adornee = target
	board.Parent = target
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1,1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextSize = 25
	text.TextColor3 = C(255,223,135)
	text.TextStrokeTransparency = 0.3
	text.Text = amount and tostring(amount) or "✓"
	text.Parent = board
	TweenService:Create(board,TweenInfo.new(0.7),{StudsOffsetWorldSpace=V(0,5.5,0)}):Play()
	TweenService:Create(text,TweenInfo.new(0.7),{TextTransparency=1,TextStrokeTransparency=1}):Play()
	Debris:AddItem(board,0.75)
	local light = Instance.new("PointLight")
	light.Color = C(255,214,111)
	light.Brightness = 2
	light.Range = 7
	light.Parent = target
	TweenService:Create(light,TweenInfo.new(0.2),{Brightness=0}):Play()
	Debris:AddItem(light,0.25)
end

return Visual
