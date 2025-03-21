class_name Player
extends CharacterBody2D

# All of these are being tested and might not be in the final game(Double Jump might be a perk)
enum Special {
	None,
	SecondDash, # Done
	Parry,
	GroundSlam,
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
