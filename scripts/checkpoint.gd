extends Node2D

var is_activated: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		activate()
		
func activate():
	is_activated = true
	GameManager.set_checkpoint(get_parent().name, global_position)

	print_debug(str("Activated at: ", global_position))
