class_name HitArea
extends Area2D


@export var player: Player
@export var FORCE: float

var body_in_area: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.dashing && body_in_area != null && player.time_mult == 1.0:
		body_in_area.hit_velocity += FORCE * player.get_distance(player, body_in_area).normalized()
		player.hit_velocity = (FORCE / 1.5) * -player.get_distance(player, body_in_area).normalized()
		player.dashing = false
		body_in_area.dash_stun = body_in_area.DASH_STUN
		body_in_area.hit_reversed = false

		if body_in_area.parry_buffer > 0.0:
			player.hit_velocity = -body_in_area.PARRY_FORCE * player.direction.normalized()
			player.dashing = false
			player.dash_stun = body_in_area.DASH_STUN
			player.can_dash = false
			

		# Character Idea
		# player.can_dash = true
		# player.dash_time = player.DASH_TIME
	pass


func _on_body_entered(body):
	if body is Player && body != player:
		body_in_area = body
	pass # Replace with function body.


func _on_body_exited(body):
	if body is Player:
		body_in_area = null
	pass # Replace with function body.
