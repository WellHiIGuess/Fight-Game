extends Area2D


func _on_body_entered(body):
	if body is Player:
		body.respawn()
	pass # Replace with function body.
