class_name Player
extends CharacterBody2D

# All of these are being tested and might not be in the final game(Double Jump might be a perk)
enum Special {
	None,
	SecondDash, # Done
	Parry,
	TimeSlow,
	StunShot,
	RadialShove,
	Teleport,
	GrapplingHook,
	MirrorImage,
	SpawnBlock,
	DoubleJump,
	Random,
}

# All of these are being tested and might not be in the final game(Double Jump might be a special)
enum Perk {
	None,
	SizeIncrease,
	SizeDecrease,
	SpeedIncrease,
	DashSpeedIncrease,
	BiggerHitArea,
	HarderDash,
	SquareCollider,
	# To be implimented
	KonamiCode,
	Random,
}

@export var special: Special = Special.None
@export var perk: Perk = Perk.None
@export var player_num: String

func get_distance(player1: Player, player2: Player) -> Vector2:
	return (player2.global_position) - (player1.global_position)
