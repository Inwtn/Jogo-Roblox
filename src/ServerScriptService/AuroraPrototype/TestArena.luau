-- Adaptador dos sistemas de jogo para o mapa persistente e editável.
local WorldBuilder = require(script.Parent.WorldBuilder)
local TestArena = {}

function TestArena.Create()
	local world = WorldBuilder.Build()
	local actors = world:WaitForChild("Personagens")
	local markers = world:WaitForChild("Marcadores")
	local trainer = actors.InstrutorAldric.Torso
	local dummy = actors.BonecoDeTreino.Alvo
	local enemies = Instance.new("Folder")
	enemies.Name = "AuroraEnemies"
	enemies.Parent = workspace
	local positions = {}
	for _, marker in markers:GetChildren() do
		if marker.Name:match("^SlimeSpawn") then table.insert(positions, marker.Position) end
	end
	return {
		Arena = world, Spawn = markers.AuroraSpawn, TrainerPrompt = trainer.Conversar,
		Dummy = dummy, DummyPrompt = dummy.AtacarBoneco, Enemies = enemies, SlimePositions = positions,
	}
end

return TestArena
