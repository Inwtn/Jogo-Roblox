-- Executar como Script temporário no ServerScriptService durante Play local.
-- O require da Command Bar usa outro contexto; crie um Script com este Source.
-- Requer um jogador com Q01. Altera apenas o progresso desta sessão de teste.
assert(game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsRunning(), "Execute durante Play no Studio")
local code=game.ServerScriptService:FindFirstChild("AuroraGame") or game.ServerScriptService.AuroraPrototype
local Data=require(code.DataService)
local Quest=require(code.QuestService)
local Enemy=require(code.EnemyService)
local Config=require(code.Config)
local player=assert(game.Players:GetPlayers()[1], "Entre com um jogador")
local state=assert(Data.Get(player), "Perfil ainda não carregou")
assert(state.ReadOnly, "Use um teste local sem salvamento")
assert(state.Data.QuestState.Id=="Q01", "Inicie outra sessão para repetir")
local character=player.Character
local root=character.HumanoidRootPart
local world=workspace.AuroraWorld
local dummy=world.Personagens.BonecoDeTreino.Alvo
local trainer=world.Personagens.InstrutorAldric.Torso
assert(world:GetAttribute("Ready") and character:FindFirstChild("AuroraEquipment"), "Mapa ou equipamento ausente")
root:SetNetworkOwner(nil)
local ok,problem=xpcall(function()
	character:PivotTo(CFrame.new(trainer.Position+Vector3.new(0,1,5)))
	if not state.Data.QuestState.Spoke then Quest.Trainer(player) end
	if not state.Data.QuestState.DummyHit then
		character:PivotTo(CFrame.new(dummy.Position+Vector3.new(0,1,5)))
		Enemy.Attack(player,dummy,dummy)
	end
	assert(state.Data.QuestState.DummyHit, "Treino não registrou")
	character:PivotTo(CFrame.new(trainer.Position+Vector3.new(0,1,5)))
	Quest.Trainer(player)
	assert(state.Data.QuestState.Id=="Q02" and state.Data.Gold==10, "Recompensa Q01 incorreta")
	local enemies=workspace.AuroraEnemies:GetChildren()
	assert(#enemies==3, "Quantidade de slimes incorreta")
	task.wait(Config.Paladin.AttackCooldown+0.1)
	Enemy.Attack(player,enemies[1].Body,dummy)
	assert(enemies[1]:GetAttribute("Health")==Config.Slime.MaxHealth, "Ataque fora do alcance aceito")
	for _,slime in enemies do
		character:PivotTo(CFrame.new(slime.Body.Position+Vector3.new(0,1,3)))
		task.wait(Config.Paladin.AttackCooldown+0.1)
		Enemy.Attack(player,slime.Body,dummy)
		local health=slime:GetAttribute("Health")
		assert(health==Config.Slime.MaxHealth-Config.Paladin.AttackDamage, "Dano incorreto")
		Enemy.Attack(player,slime.Body,dummy)
		assert(slime:GetAttribute("Health")==health, "Cooldown ignorado")
		task.wait(Config.Paladin.AttackCooldown+0.1)
		Enemy.Attack(player,slime.Body,dummy)
		assert(slime:GetAttribute("Health")==0, "Slime não morreu")
	end
	assert(state.Data.QuestState.Kills==3, "Abates não contados")
	character:PivotTo(CFrame.new(trainer.Position+Vector3.new(0,1,5)))
	Quest.Trainer(player)
	assert(state.Data.QuestState.Id=="DONE" and state.Data.Gold==30, "Recompensa Q02 incorreta")
	assert(state.Data.Equipped.Weapon=="paladin_rare" and state.Data.Level==2 and state.Data.XP==90, "Progressão incorreta")
	local weapons=#state.Data.Inventory.Weapons
	Quest.Trainer(player)
	assert(state.Data.Gold==30 and #state.Data.Inventory.Weapons==weapons, "Recompensa duplicada")
	task.wait(Config.Slime.RespawnSeconds+0.2)
	for _,slime in enemies do assert(slime:GetAttribute("Health")==Config.Slime.MaxHealth and slime.Body.Transparency==0, "Respawn incorreto") end
	print("AURORA_SMOKE_OK: Q01, Q02, alcance, cooldown, 3 abates, recompensas únicas, nível, equipamento e respawn")
end,debug.traceback)
root:SetNetworkOwnershipAuto()
assert(ok,problem)
