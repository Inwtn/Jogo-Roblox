local Art = require(script.Parent.Art)
local Config = require(script.Parent.Config)
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Terrain = workspace.Terrain
local V, C = Vector3.new, Color3.fromRGB
local World = { Origin=V(Config.TestArenaCenter.X,0,Config.TestArenaCenter.Z), Version=2 }
local function smooth(a,b,t)
	t=math.clamp((t-a)/(b-a),0,1)
	return t*t*(3-2*t)
end
local function roadX(z) return 5+10*math.sin(-z/45) end
local function riverX(z) return 77+10*math.sin(z/33) end

function World.Height(x,z)
	local noise=math.noise(x/58,z/58,17)*5 + math.noise(x/22,z/22,8)*1.6
	local village=1-smooth(29,53,math.max(math.abs(x+10)*0.7,math.abs(z-5)))
	local hill=27*math.exp(-((x+102)^2/2100+(z+110)^2/2300))
	local mountain=40*math.exp(-((x-12)^2/5200+(z+207)^2/1200))
	local height=6+noise*(1-village)+hill+mountain+smooth(18,65,-z)*2.8
	local clearing=(1-smooth(12,26,math.abs(x-10)))*(1-smooth(9,25,math.abs(z+167)))
	height=height*(1-clearing)+16*clearing
	local coast=math.sqrt((x/169)^2+((z+65)/206)^2)
	height-=smooth(0.78,1.05,coast)*39
	if z>-146 and z<70 then
		local river=1-smooth(4,10,math.abs(x-riverX(z)))
		height=height*(1-river)+1.4*river
	end
	return height
end
local groundFilter=RaycastParams.new()
groundFilter.FilterType=Enum.RaycastFilterType.Include
groundFilter.FilterDescendantsInstances={Terrain}
groundFilter.IgnoreWater=true
function World.Point(x,z,offset)
	local hit=workspace:Raycast(World.Origin+V(x,110,z),V(0,-180,0),groundFilter)
	local height=hit and hit.Position.Y or World.Height(x,z)
	return World.Origin+V(x,height+(offset or 0),z)
end

local function createTerrain()
	local region=Region3.new(World.Origin+V(-192,-32,-272),World.Origin+V(192,96,144)):ExpandToGrid(4)
	local size=region.Size/4
	local materials,occupancy={},{}
	for ix=1,size.X do
		materials[ix]={}; occupancy[ix]={}
		for iy=1,size.Y do materials[ix][iy]={}; occupancy[ix][iy]={} end
		local x=-192+(ix-0.5)*4
		for iz=1,size.Z do
			local z=-272+(iz-0.5)*4
			local h=World.Height(x,z)
			local road=math.abs(x-roadX(z))<6.3+math.noise(z/12,3)*1.7 and z<25 and z>-164
			local plaza=((x+7)/22)^2+((z-9)/24)^2<1
			local housePath=x>-49 and x<5 and math.abs(z+13)<5
			local surface=(road or plaza or housePath) and Enum.Material.Ground or Enum.Material.Grass
			local edge=math.abs(World.Height(x+2,z)-h)+math.abs(World.Height(x,z+2)-h)
			if edge>4.5 or h>29 then surface=Enum.Material.Rock end
			if h<3 then surface=Enum.Material.Sand end
			local water=(math.abs(x-riverX(z))<9 and z>-146 and z<70) and 3.4 or -3
			for iy=1,size.Y do
				local bottom=-32+(iy-1)*4
				local filled=math.clamp((h-bottom)/4,0,1)
				local mat=filled>0 and (bottom>h-7 and surface or Enum.Material.Rock) or Enum.Material.Air
				if filled==0 and bottom<water then filled=math.clamp((water-bottom)/4,0,1); mat=Enum.Material.Water end
				materials[ix][iy][iz]=mat; occupancy[ix][iy][iz]=filled
			end
		end
		if ix%12==0 then task.wait() end
	end
	Terrain:WriteVoxels(region,4,materials,occupancy)
	Terrain:SetMaterialColor(Enum.Material.Grass,C(91,133,58))
	Terrain:SetMaterialColor(Enum.Material.Ground,C(157,126,85))
	Terrain:SetMaterialColor(Enum.Material.Rock,C(109,118,114))
	Terrain:SetMaterialColor(Enum.Material.Sand,C(198,181,137))
	Terrain.WaterColor=C(48,123,136); Terrain.WaterTransparency=0.35; Terrain.WaterReflectance=0.25
	Terrain.WaterWaveSize=0.12; Terrain.WaterWaveSpeed=8
	-- Decoration é configurada no arquivo .rbxlx, pois não é scriptável.
end

function World.Lighting()
	Lighting.ClockTime=15.2; Lighting.Brightness=2.6; Lighting.GlobalShadows=true
	Lighting.Ambient=C(93,104,120); Lighting.OutdoorAmbient=C(124,141,157)
	Lighting.EnvironmentDiffuseScale=0.65; Lighting.EnvironmentSpecularScale=0.5; Lighting.ExposureCompensation=0.05
	local atmosphere=Lighting:FindFirstChild("AuroraAtmosphere") or Instance.new("Atmosphere")
	atmosphere.Name="AuroraAtmosphere"; atmosphere.Density=0.25; atmosphere.Offset=0.12
	atmosphere.Color=C(213,227,235); atmosphere.Decay=C(151,177,192); atmosphere.Glare=0.1; atmosphere.Haze=1.5; atmosphere.Parent=Lighting
	local grade=Lighting:FindFirstChild("AuroraColor") or Instance.new("ColorCorrectionEffect")
	grade.Name="AuroraColor"; grade.Saturation=0.08; grade.Contrast=0.1; grade.Brightness=0.01; grade.TintColor=C(255,246,229); grade.Parent=Lighting
	local bloom=Lighting:FindFirstChild("AuroraBloom") or Instance.new("BloomEffect")
	bloom.Name="AuroraBloom"; bloom.Intensity=0.12; bloom.Size=18; bloom.Threshold=1.5; bloom.Parent=Lighting
	local clouds=Terrain:FindFirstChild("AuroraClouds") or Instance.new("Clouds")
	clouds.Name="AuroraClouds"; clouds.Cover=0.35; clouds.Density=0.45; clouds.Color=C(253,249,236); clouds.Parent=Terrain
end

local function caption(part,text,color,offset)
	local gui=Instance.new("BillboardGui")
	gui.Name="Nameplate"; gui.Size=UDim2.fromOffset(180,52); gui.StudsOffsetWorldSpace=V(0,offset,0)
	gui.MaxDistance=36; gui.AlwaysOnTop=true; gui.Adornee=part; gui.Parent=part
	local label=Instance.new("TextLabel")
	label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Font=Enum.Font.GothamBold
	label.TextSize=15; label.Text=text; label.TextColor3=color; label.TextStrokeTransparency=0.35; label.Parent=gui
end
local function prompt(part,name,action,object,key)
	local p=Instance.new("ProximityPrompt")
	p.Name=name; p.ActionText=action; p.ObjectText=object; p.KeyboardKeyCode=key
	p.MaxActivationDistance=9; p.HoldDuration=0; p.RequiresLineOfSight=false; p.Parent=part
end
local function cave(parent)
	local m=Art.Model(parent,"GrutaDosCristais")
	local entrance=World.Point(10,-169)
	for depth=0,30,3 do Terrain:FillBall(entrance+V(0,6,-depth),9,Enum.Material.Air) end
	Terrain:FillBlock(CFrame.new(entrance+V(0,-1,-13)),V(18,2,38),Enum.Material.Rock)
	for i=0,8 do
		local angle=i*math.pi/8
		Art.Rock(m,entrance+V(math.cos(angle)*11,math.sin(angle)*12+0.5,2),1.5,70+i)
	end
	for _,entry in {{-7,1,-4},{7,0,-9},{-5,0,-20},{6,0,-27}} do
		local pos=entrance+V(entry[1],entry[2],entry[3])
		for k=1,3 do
			local crystal=Art.Part(m,"Cristal",V(1.1,3.4+k,1.2),CFrame.new(pos+V((k-2)*0.9,1.4,0))*CFrame.Angles(0,0,math.rad((k-2)*21)),C(94,192,212),Enum.Material.Neon,"Wedge")
			if k==2 then local l=Instance.new("PointLight"); l.Color=C(82,182,224); l.Brightness=1; l.Range=17; l.Parent=crystal end
		end
	end
end

function World.Build()
	local existing=workspace:FindFirstChild("AuroraWorld")
	if existing then return existing end -- preserva edições manuais.
	createTerrain()
	-- Aguarda o Studio atualizar a colisão dos voxels antes de posicionar os modelos.
	task.wait(0.2)
	World.Lighting()
	local world=Art.Model(workspace,"AuroraWorld")
	world:SetAttribute("ArtVersion",World.Version); world:SetAttribute("Origin",World.Origin)
	local village=Art.Model(world,"VilaDaAurora")
	local vegetation=Art.Model(world,"Vegetacao")
	local rocks=Art.Model(world,"Rochas")
	local props=Art.Model(world,"Aderecos")
	local actors=Art.Model(world,"Personagens")
	local markers=Instance.new("Folder"); markers.Name="Marcadores"; markers.Parent=world
	Art.Cottage(village,World.Point(-32,-11),78,1.05,"PousadaDaAurora")
	Art.Cottage(village,World.Point(-38,-44),63,0.83,"CasaDoFerreiro")
	Art.Cottage(village,World.Point(39,14),-83,0.8,"CasaDoInstrutor")
	for i,entry in {{-60,12,1.4},{-66,-34,1.5},{-64,-76,1.7},{-48,-109,1.4},{-27,-132,1.2},{48,-36,1.6},{51,-82,1.5},{55,-124,1.1},{99,-65,1.3},{100,-116,1.6},{-92,-140,1.5},{-108,-63,1.3},{38,46,1.5},{-45,43,1.3},{-94,8,1.2},{111,12,1.4},{-64,-158,1.2},{-35,-197,1.1},{70,-179,1.2}} do
		Art.Tree(vegetation,World.Point(entry[1],entry[2]),entry[3],i*87)
	end
	for i,entry in {{-15,-46,1.1},{31,-59,1.5},{-29,-80,1.4},{36,-104,1.2},{-47,-126,2},{42,-144,1.8},{-65,-99,2},{83,-30,0.9},{-16,33,0.8},{23,31,0.7}} do
		Art.Rock(rocks,World.Point(entry[1],entry[2]),entry[3],i*41)
	end
	Art.Fence(props,World.Point(-18,-29),World.Point(-20,-55))
	Art.Fence(props,World.Point(28,-30),World.Point(33,-53))
	Art.Fence(props,World.Point(-25,24),World.Point(-48,25))
	for _,entry in {{-14,-9},{22,-27},{-4,-61}} do
		local pos=World.Point(entry[1],entry[2])
		Art.Beam(props,"PosteDeLanterna",pos,pos+V(0,8,0),0.6,C(91,61,39),Enum.Material.Wood,true)
		Art.Beam(props,"Suporte",pos+V(0,8,0),pos+V(1.9,8,0),0.4,C(91,61,39),Enum.Material.Wood)
		Art.Lantern(props,CFrame.new(pos+V(1.8,6.8,0)))
	end
	for _,entry in {{-20,-4},{-22,-6},{-26,-28},{28,7}} do Art.Barrel(props,CFrame.new(World.Point(entry[1],entry[2],1.3))) end
	local well=Art.Model(props,"PocoDaVila")
	local wellPos=World.Point(-29,15)
	for i=1,12 do
		local angle=i*math.pi/6
		Art.Part(well,"Pedra",V(1.8,2,1.2),CFrame.new(wellPos+V(math.sin(angle)*2.8,1,math.cos(angle)*2.8))*CFrame.Angles(0,angle,0),C(138+i%3*7,142+i%3*6,128),Enum.Material.Cobblestone,nil,true)
	end
	for _,x in {-3.4,3.4} do Art.Beam(well,"Suporte",wellPos+V(x,0,0),wellPos+V(x,7,0),0.65,C(99,67,42),Enum.Material.Wood,true) end
	Art.Beam(well,"Eixo",wellPos+V(-3.5,5,0),wellPos+V(3.5,5,0),0.35,C(99,67,42),Enum.Material.Wood,true)
	local rand=Random.new(4102)
	for i=1,90 do
		local x,z=rand:NextNumber(-60,60),rand:NextNumber(-148,35)
		if math.abs(x-roadX(z))>9 and not (x< -16 and z> -62) and not (x>24 and z> -14) then Art.Flower(vegetation,World.Point(x,z,0.15),i*73) end
	end
	for i=1,46 do
		local z=rand:NextNumber(-143,24)
		local x=roadX(z)+(i%2==0 and 1 or -1)*rand:NextNumber(6,8.5)
		Art.Part(props,"Seixo",V(rand:NextNumber(0.3,0.9),0.25,rand:NextNumber(0.3,0.7)),World.Point(x,z,0.15),C(162,155,128),Enum.Material.Rock,"Ball")
	end
	cave(world)
	local _,trainer=Art.Trainer(actors,World.Point(-9,-3))
	caption(trainer,"!\nAldric · Instrutor",C(255,217,125),4.2)
	prompt(trainer,"Conversar","Conversar","Aldric, instrutor da Aurora",Enum.KeyCode.E)
	local _,dummy=Art.Dummy(actors,World.Point(8,-16))
	caption(dummy,"Treinamento",C(241,222,175),3.5)
	prompt(dummy,"AtacarBoneco","Atacar","Boneco de treino",Enum.KeyCode.F)
	local spawn=Instance.new("SpawnLocation")
	spawn.Name="AuroraSpawn"; spawn.Size=V(5,0.5,5); spawn.CFrame=CFrame.new(World.Point(-4,13,0.2))
	spawn.Anchored=true; spawn.CanCollide=false; spawn.Transparency=1; spawn.Neutral=true; spawn.Duration=0; spawn.Parent=markers
	for i,entry in {{10,-62},{-4,-86},{19,-107}} do
		local mark=Art.Part(markers,"SlimeSpawn"..i,V(1,1,1),World.Point(entry[1],entry[2],2),C(95,210,99))
		mark.Transparency=1; mark.CanQuery=false; mark.CanTouch=false
	end
	world:SetAttribute("Ready",true)
	if not RunService:IsRunning() and workspace.CurrentCamera then
		local target=World.Point(1,-70,7)
		workspace.CurrentCamera.Focus=CFrame.new(target)
		workspace.CurrentCamera.CFrame=CFrame.lookAt(World.Point(4,34,12),target)
	end
	print("Aurora: mapa construído. Salve o lugar para manter terreno e modelos editáveis.")
	return world
end
return World
