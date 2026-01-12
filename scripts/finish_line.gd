extends Node2D

signal finish_line_reached

var tween: Tween

func _ready() -> void:
    tween = get_tree().create_tween().set_loops()
    tween.tween_property(self, "position:y", position.y - 2, 1).set_trans(Tween.TRANS_SINE)
    tween.tween_property(self, "position:y", position.y + 2, 1).set_trans(Tween.TRANS_SINE)

func _on_area_2d_body_entered(body: Node2D) -> void:
    if body.is_in_group("Player"):
        GameManager.finish_game()
