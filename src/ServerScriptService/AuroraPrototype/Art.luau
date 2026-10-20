-- Biblioteca de cenário original. Cada objeto continua editável no Studio.
local Art = {}
local V = Vector3.new
local C = Color3.fromRGB
local wood, darkWood = C(112, 73, 43), C(66, 45, 32)
local gold, blue = C(201, 153, 67), C(44, 86, 133)

function Art.Model(parent, name)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	return model
end

function Art.Part(parent, name, size, cf, color, material, shape, collide)
	local p = Instance.new(shape == "Wedge" and "WedgePart" or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = typeof(cf) == "Vector3" and CFrame.new(cf) or cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = collide == true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape == "Ball" then p.Shape = Enum.PartType.Ball end
	if shape == "Cylinder" then p.Shape = Enum.PartType.Cylinder end
	p.Parent = parent
	return p
end

function Art.Beam(parent, name, a, b, width, color, material, round)
	local mid = (a + b) * 0.5
	local cf = CFrame.lookAt(mid, b)
	if round then
		return Art.Part(parent, name, V((b-a).Magnitude, width, width), cf * CFrame.Angles(0, math.pi/2, 0), color, material, "Cylinder")
	end
	return Art.Part(parent, name, V(width, width, (b-a).Magnitude), cf, color, material)
end

local function oval(parent, name, position, size, color, material)
	return Art.Part(parent, name, size, position, color, material, "Ball")
end

-- Superfícies trianguladas para copas com silhueta irregular e faces amplas.
local function triangle(parent,a,b,c,color)
	local ab,ac,bc=b-a,c-a,c-b
	if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then c,a=a,c
	elseif ac:Dot(ac)>bc:Dot(bc) then a,b=b,a end
	ab,ac,bc=b-a,c-a,c-b
	local right=ac:Cross(ab).Unit
	local up=bc:Cross(right).Unit
	local back=bc.Unit
	local height=math.abs(ab:Dot(up))
	Art.Part(parent,"Folha",V(0.05,height,math.abs(ab:Dot(back))),CFrame.fromMatrix((a+b)/2,right,up,back),color,Enum.Material.SmoothPlastic,"Wedge")
	Art.Part(parent,"Folha",V(0.05,height,math.abs(ac:Dot(back))),CFrame.fromMatrix((a+c)/2,-right,up,-back),color,Enum.Material.SmoothPlastic,"Wedge")
end

local function crown(parent,position,size,color,seed)
	local m=Art.Model(parent,"CopaModelada")
	local t=(1+math.sqrt(5))/2
	local points={V(-1,t,0),V(1,t,0),V(-1,-t,0),V(1,-t,0),V(0,-1,t),V(0,1,t),V(0,-1,-t),V(0,1,-t),V(t,0,-1),V(t,0,1),V(-t,0,-1),V(-t,0,1)}
	local faces={{1,12,6},{1,6,2},{1,2,8},{1,8,11},{1,11,12},{2,6,10},{6,12,5},{12,11,3},{11,8,7},{8,2,9},{4,10,5},{4,5,3},{4,3,7},{4,7,9},{4,9,10},{5,10,6},{3,5,12},{7,3,11},{9,7,8},{10,9,2}}
	local r=Random.new(seed)
	for i,p in points do points[i]=position+p.Unit*size*0.57*r:NextNumber(0.88,1.13) end
	for _,f in faces do
		local variation=r:NextNumber(-0.045,0.045)
		local shade=C(math.clamp(color.R*255+variation*255,0,255),math.clamp(color.G*255+variation*255,0,255),math.clamp(color.B*255+variation*140,0,255))
		triangle(m,points[f[1]],points[f[2]],points[f[3]],shade)
	end
	return m
end

function Art.Tree(parent, position, scale, seed)
	local model = Art.Model(parent, "Carvalho")
	local r = Random.new(seed)
	local function pt(x, y, z) return position + V(x, y, z) * scale end
	local trunk = Art.Beam(model, "Tronco", pt(0,0,0), pt(0.7,11,0.2), 2.3*scale, wood, Enum.Material.Wood, true)
	trunk.CanCollide = true
	for i=1,5 do
		local angle = i*math.pi*2/5
		Art.Beam(model, "Raiz", pt(math.cos(angle)*2.7,0.1,math.sin(angle)*2.7), pt(0,2.3,0), 0.8*scale, darkWood, Enum.Material.Wood, true)
		local x, z = math.cos(angle)*4.7, math.sin(angle)*4.7
		Art.Beam(model, "Galho", pt(0.4,7.5,0), pt(x,12.8,z), 0.8*scale, wood, Enum.Material.Wood, true)
		crown(model,pt(x,14+r:NextNumber(-1,1),z),V(9,7,8)*scale,
			C(r:NextInteger(58,83),r:NextInteger(117,147),r:NextInteger(43,61)),seed+i*137)
	end
	crown(model,pt(0.8,17,0),V(10,8,9)*scale,C(91,151,61),seed+949)
	return model
end

function Art.Rock(parent, position, scale, seed)
	local r = Random.new(seed)
	local model = Art.Model(parent, "RochaMusgosa")
	local cf = CFrame.new(position) * CFrame.Angles(0,r:NextNumber(0,6.28),0)
	Art.Part(model,"Nucleo",V(4.5,3,4)*scale,cf*CFrame.new(0,1.1*scale,0)*CFrame.Angles(0.2,0,0.12),C(112,121,115),Enum.Material.Rock,"Ball",true)
	for i=1,3 do
		Art.Part(model,"Face",V(2.8,2.6,3.1)*scale,cf*CFrame.new((i-2)*1.4*scale,0.8*scale,0)*CFrame.Angles(0,i*1.7,0),
			C(101+i*6,111+i*6,108+i*5),Enum.Material.Rock,"Wedge",true)
	end
	oval(model,"Musgo",position+V(0,2.5,0)*scale,V(3.3,0.5,2.6)*scale,C(100,130,66),Enum.Material.Grass)
	return model
end

function Art.Lantern(parent, cf)
	local model = Art.Model(parent,"Lanterna")
	Art.Part(model,"Base",V(1.1,0.2,1.1),cf*CFrame.new(0,-0.7,0),darkWood,Enum.Material.Metal)
	Art.Part(model,"Tampa",V(1.3,0.3,1.3),cf*CFrame.new(0,0.7,0),darkWood,Enum.Material.Metal)
	local flame=Art.Part(model,"Luz",V(0.65,1.15,0.65),cf,C(255,207,122),Enum.Material.Neon)
	for _,x in {-0.45,0.45} do for _,z in {-0.45,0.45} do
		Art.Part(model,"Grade",V(0.12,1.4,0.12),cf*CFrame.new(x,0,z),darkWood,Enum.Material.Metal)
	end end
	local light=Instance.new("PointLight")
	light.Color=C(255,193,111); light.Range=15; light.Brightness=0.8; light.Shadows=true; light.Parent=flame
	return model
end

function Art.Cottage(parent, position, yaw, scale, name)
	local m=Art.Model(parent,name)
	local cf=CFrame.new(position)*CFrame.Angles(0,math.rad(yaw),0)
	local function p(n,s,v,col,mat,shape,rot,collide)
		return Art.Part(m,n,s*scale,cf*CFrame.new(v*scale)*(rot or CFrame.identity),col,mat,shape,collide)
	end
	p("Fundacao",V(19,1.8,17),V(0,0.9,0),C(122,123,112),Enum.Material.Cobblestone,nil,nil,true)
	p("Reboco",V(17,10,15),V(0,6.6,0),C(230,210,165),Enum.Material.Plaster,nil,nil,true)
	for _,x in {-8.5,0,8.5} do p("Coluna",V(0.7,10.8,0.8),V(x,6.6,7.55),darkWood,Enum.Material.Wood) end
	for _,z in {-7.5,7.5} do
		for _,y in {2,6,11.5} do p("Viga",V(18,0.65,0.7),V(0,y,z),wood,Enum.Material.Wood) end
		for _,x in {-8.5,8.5} do p("Canto",V(0.8,10.6,0.8),V(x,6.6,z),darkWood,Enum.Material.Wood) end
	end
	for _,x in {-8.55,8.55} do
		for _,y in {2,6,11.5} do p("Lateral",V(0.7,0.65,15),V(x,y,0),wood,Enum.Material.Wood) end
	end
	for _,x in {-4.5,4.5} do
		p("Contraventamento",V(0.5,5.8,0.5),V(x,8.8,7.7),wood,Enum.Material.Wood,nil,CFrame.Angles(0,0,math.rad(x<0 and -42 or 42)))
	end
	-- Duas águas com beiral, cumeeira e fileiras de telhas sobrepostas.
	for _,side in {-1,1} do
		local angle=math.rad(-side*36)
		p("ForroDoTelhado",V(11.6,0.65,18.6),V(side*4.55,14.6,0),darkWood,Enum.Material.Wood,nil,CFrame.Angles(0,0,angle),true)
		for row=0,4 do for column=0,6 do
			local along=(row-2)*2.1
			local roofCf=cf*CFrame.new(V(side*4.55,14.95,0)*scale)*CFrame.Angles(0,0,angle)*CFrame.new(along*scale,0,(column-3)*2.65*scale)
			Art.Part(m,"TelhaAzul",V(2.24,0.28,2.72)*scale,roofCf,C(41+row*3,77+column%3*6,119+row*4),Enum.Material.Slate)
		end end
	end
	p("Cumeeira",V(0.75,0.7,19.3),V(0,18,0),blue,Enum.Material.Slate)
	-- Frontão e vigas sob o telhado.
	for _,side in {-1,1} do
		p("VigaInclinada",V(0.7,11.2,0.8),V(side*4.55,14.8,7.9),wood,Enum.Material.Wood,nil,CFrame.Angles(0,0,math.rad(side*54)))
	end
	for _,z in {-7.5,7.5} do
		for y=12,17 do
			p("Frontao",V((18-y)*2/0.727-0.9,1.05,0.6),V(0,y,z),C(222,201,154),Enum.Material.Plaster)
		end
	end
	p("PilarFrontao",V(0.6,6.1,0.8),V(0,14.7,7.8),wood,Enum.Material.Wood)
	-- Porta, moldura, tábuas e degraus.
	p("ArcoDaPorta",V(4.8,7,0.7),V(0,5,7.85),darkWood,Enum.Material.Wood)
	for i=0,5 do p("TabuaDaPorta",V(0.61,6.2,0.3),V(-1.55+i*0.62,4.65,8.3),C(130+i%2*8,85,48),Enum.Material.WoodPlanks) end
	for _,y in {3.2,6} do p("Ferragem",V(3.7,0.22,0.12),V(0,y,8.5),C(55,62,65),Enum.Material.Metal) end
	p("Macaneta",V(0.35,0.35,0.2),V(1.1,4.6,8.6),gold,Enum.Material.Metal,"Ball")
	for i=1,3 do p("Degrau",V(5.6,0.4*i,1.3),V(0,0.2*i,12-i*1.15),C(148,145,126),Enum.Material.Cobblestone,nil,nil,true) end
	for _,x in {-5.6,5.6} do
		p("Moldura",V(3.3,4.3,0.6),V(x,5.1,7.9),darkWood,Enum.Material.Wood)
		p("Vidro",V(2.5,3.5,0.1),V(x,5.1,8.25),C(245,186,87),Enum.Material.Neon)
		p("Caixilho",V(0.18,3.6,0.25),V(x,5.1,8.4),wood,Enum.Material.Wood)
		p("Caixilho",V(2.6,0.18,0.25),V(x,5.1,8.4),wood,Enum.Material.Wood)
		for _,side in {-1,1} do p("Veneziana",V(0.7,3.8,0.3),V(x+side*1.8,5.1,8.4),blue,Enum.Material.WoodPlanks) end
		p("Floreira",V(3.5,0.7,1),V(x,2.8,8.3),wood,Enum.Material.WoodPlanks)
		for k=1,5 do p("FloresDaJanela",V(0.6,0.6,0.6),V(x-1.3+k*0.43,3.35,8.4),k%2==0 and C(236,167,120) or C(244,217,136),Enum.Material.SmoothPlastic,"Ball") end
	end
	p("Chamine",V(2.6,8,2.6),V(5,16,-3),C(125,121,108),Enum.Material.Brick,nil,nil,true)
	p("BocaChamine",V(3.3,0.6,3.3),V(5,20,-3),C(80,85,80),Enum.Material.Cobblestone)
	Art.Lantern(m,cf*CFrame.new(V(3,7.5,9)*scale))
	return m
end

function Art.Fence(parent,a,b)
	local m=Art.Model(parent,"CercaRustica")
	local count=math.max(1,math.ceil((b-a).Magnitude/8))
	for i=0,count do
		local pos=a:Lerp(b,i/count)
		Art.Part(m,"Mourao",V(0.65,3.7,0.7),pos+V(0,1.6,0),wood,Enum.Material.Wood,nil,true)
		Art.Part(m,"Topo",V(0.82,0.35,0.85),pos+V(0,3.5,0),darkWood,Enum.Material.Wood)
	end
	for _,y in {1,2.5} do Art.Beam(m,"Travessa",a+V(0,y,0),b+V(0,y,0),0.45,wood,Enum.Material.Wood) end
	return m
end

function Art.Barrel(parent,cf)
	local m=Art.Model(parent,"Barril")
	Art.Part(m,"Madeira",V(2.6,2,2),cf*CFrame.Angles(0,0,math.pi/2),wood,Enum.Material.WoodPlanks,"Cylinder",true)
	for _,y in {-0.85,0.85} do Art.Part(m,"Aro",V(0.16,2.08,2.08),cf*CFrame.new(0,y,0)*CFrame.Angles(0,0,math.pi/2),C(71,78,75),Enum.Material.Metal,"Cylinder") end
	return m
end

function Art.Flower(parent,position,seed)
	local m=Art.Model(parent,"FloresDoPrado")
	local r=Random.new(seed)
	local col=seed%3==0 and C(143,169,217) or C(243,221,155)
	for i=1,3 do
		local pos=position+V(r:NextNumber(-1,1),0,r:NextNumber(-1,1))
		local height=r:NextNumber(0.65,1.2)
		Art.Beam(m,"Haste",pos,pos+V(0,height,0),0.08,C(69,111,50),Enum.Material.Grass)
		for k=1,4 do
			local angle=k*math.pi/2
			oval(m,"Petala",pos+V(math.cos(angle)*0.16,height,math.sin(angle)*0.16),V(0.3,0.12,0.3),col)
		end
		oval(m,"Miolo",pos+V(0,height+0.05,0),V(0.15,0.15,0.15),gold)
	end
	return m
end

function Art.Trainer(parent,position)
	local m=Art.Model(parent,"InstrutorAldric")
	local cf=CFrame.new(position)*CFrame.Angles(0,math.rad(-15),0)
	local function p(n,size,pos,col,mat,shape) return Art.Part(m,n,size,cf*CFrame.new(pos),col,mat,shape) end
	p("Perna",V(0.8,2,0.9),V(-0.5,1.1,0),C(49,53,59))
	p("Perna",V(0.8,2,0.9),V(0.5,1.1,0),C(49,53,59))
	for _,x in {-0.5,0.5} do p("Bota",V(0.9,0.7,1.2),V(x,0.35,0.15),darkWood) end
	local body=p("Torso",V(2,2.2,1),V(0,3.1,0),blue,Enum.Material.Fabric)
	p("Peitoral",V(1.7,1.3,0.2),V(0,3.4,0.58),C(163,177,183),Enum.Material.Metal)
	p("Cinto",V(2.1,0.3,1.1),V(0,2.4,0),darkWood,Enum.Material.Fabric)
	p("Fivela",V(0.4,0.4,0.15),V(0,2.4,0.62),gold,Enum.Material.Metal)
	for _,side in {-1,1} do
		p("Braco",V(0.7,1.9,0.8),V(side*1.35,3,0),blue,Enum.Material.Fabric)
		p("Ombreira",V(1.1,0.9,1.2),V(side*1.3,3.9,0),C(156,170,177),Enum.Material.Metal,"Ball")
		p("Luva",V(0.7,0.7,0.8),V(side*1.35,2.1,0),darkWood,Enum.Material.Fabric)
	end
	local head=p("Head",V(1.6,1.6,1.5),V(0,5,0),C(224,172,126))
	local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Head; mesh.Scale=V(1,1,1); mesh.Parent=head
	p("Cabelo",V(1.7,0.65,1.65),V(0,5.7,-0.05),C(79,59,43),nil,"Ball")
	for _,x in {-0.32,0.32} do p("Olho",V(0.13,0.18,0.09),V(x,5.05,0.73),C(33,36,34),nil,"Ball") end
	p("Bigode",V(0.7,0.16,0.12),V(0,4.68,0.75),C(86,63,43),nil,"Ball")
	p("Capa",V(2.1,2.8,0.2),V(0,2.8,-0.7),blue,Enum.Material.Fabric)
	return m,body
end

function Art.Dummy(parent,position)
	local m=Art.Model(parent,"BonecoDeTreino")
	Art.Beam(m,"Poste",position,position+V(0,5.6,0),0.7,wood,Enum.Material.Wood,true)
	Art.Beam(m,"Bracos",position+V(-2.5,3.8,0),position+V(2.5,3.8,0),0.55,wood,Enum.Material.Wood,true)
	local body=Art.Part(m,"Alvo",V(1.3,2.8,2.8),CFrame.new(position+V(0,3.5,0.25))*CFrame.Angles(0,math.pi/2,0),C(190,153,90),Enum.Material.Fabric,"Cylinder")
	Art.Part(m,"Circulo",V(0.1,1.8,1.8),CFrame.new(position+V(0,3.5,0.95))*CFrame.Angles(0,math.pi/2,0),C(151,65,49),Enum.Material.Fabric,"Cylinder")
	Art.Part(m,"Centro",V(0.13,0.75,0.75),CFrame.new(position+V(0,3.5,1.02))*CFrame.Angles(0,math.pi/2,0),C(239,204,137),Enum.Material.Fabric,"Cylinder")
	oval(m,"CabecaDePalha",position+V(0,5.5,0),V(1.5,1.4,1.3),C(190,153,90),Enum.Material.Fabric)
	return m,body
end

return Art
