extends Sprite2D

const ROTATION_SPEED = 15.0
const DASH_ROTATION_SPEED = 60.0

@export var player: Player

const step = deg_to_rad(7.5)

func _physics_process(delta):
	if !player.dashing:
		rotate(player.direction.x * ROTATION_SPEED * delta)
	else:
		rotate(player.direction.x * DASH_ROTATION_SPEED * delta)

	rotation = round(rotation / step) * step

	pass
