class_name WallClimb
extends Area2D


@export var player: Player

var wall

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	wall = body
	player.climbing_wall = true
	pass # Replace with function body.


func _on_body_exited(body):
	wall = null
	player.climbing_wall = false
	player.dashing = false
	pass # Replace with function body.
