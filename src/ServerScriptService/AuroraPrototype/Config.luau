local Config = {}

Config.SchemaVersion = 1
Config.DataStoreName = "AuroraProfiles_Dev_v1"
Config.MaxLevel = 10
Config.SaveInterval = 60
Config.LockSeconds = 180
Config.TestArenaCenter = Vector3.new(600, 8, 0)
Config.SafeRadius = 28

Config.Paladin = {
	MaxHealth = 100,
	AttackDamage = 18,
	AttackRange = 11,
	AttackCooldown = 0.65,
}

Config.Slime = {
	MaxHealth = 35,
	Damage = 8,
	XP = 10,
	DetectRange = 36,
	LeashRange = 38,
	AttackRange = 5,
	Speed = 7,
	AttackCooldown = 1.6,
	RespawnSeconds = 6,
}

function Config.XPToNextLevel(level)
	return 60 + 20 * level
end

return Config
