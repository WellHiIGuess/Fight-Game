class_name StunShotArea
extends HitArea

const STUN_SHOT_SPEED = 1400.0
const LIFE_TIME = 5.0

var direction = Vector2.ZERO
var default_scale_x = 0

var enabled = false
var life_time = 0.0

var time_mult = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	default_scale_x = scale.x
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		enabled = true

	if enabled:
		life_time += delta

	if life_time >= LIFE_TIME:
		queue_free()

	if direction.x > 0:
		scale.x = default_scale_x
	elif direction.x < 0:
		scale.x = -default_scale_x

	if visible && body_in_area != null && player.time_mult == 1.0:
		body_in_area.hit_velocity += FORCE * direction
		body_in_area.dash_stun = body_in_area.DASH_STUN
		free()

	pass

func _physics_process(delta):
	if visible:
		position += STUN_SHOT_SPEED * direction * time_mult * delta

func _on_body_entered(body):
	if body is Player && body != player:
		body_in_area = body
	pass # Replace with function body.


func _on_body_exited(body):
	if body is Player:
		body_in_area = null
	pass # Replace with function body.
