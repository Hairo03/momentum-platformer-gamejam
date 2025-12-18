extends Node

var player: CharacterBody2D
var current_room: String
var current_checkpoint: Vector2

func _ready() -> void:
    player = get_tree().get_first_node_in_group("Player")

func set_checkpoint(room_name: String, position: Vector2):
    current_room = room_name
    current_checkpoint = position

func respawn_player():
    if player:
        player.global_position = current_checkpoint
        player.reset()