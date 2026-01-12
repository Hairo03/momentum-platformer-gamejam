extends CanvasLayer



func _on_retry_button_pressed() -> void:
	GameManager.start_game()
	get_tree().paused = false
	queue_free()
