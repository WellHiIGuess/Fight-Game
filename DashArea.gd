extends Area2D


const WAIT = 1.0
var wait = WAIT
var active = true

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		visible = true
		wait = WAIT
	else: 
		visible = false
		wait -= delta

		if wait <= 0:
			active = true




	if player != null:
		player.can_dash = true
		player = null
	pass


func _on_body_entered(body):
	if body is Player && active:
		player = body
		active = false

	pass # Replace with function body.


func _on_body_exited(body):
	if body is Player:
		player = null
	pass # Replace with function body.
