class_name Room
extends Node2D

@export_group("Room Settings")
@export var room_id: String = "room_1_1"
@export var left_limit: int = -240
@export var top_limit: int = -135
@export var right_limit: int = 240
@export var bottom_limit: int = 135
@export var cam_pos: Node2D

@export_group("Entrypoints")
@export var left: Area2D
@export var right: Area2D

var player: CharacterBody2D = null
var is_active: bool = false
@onready var camera = get_viewport().get_camera_2d()

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func set_player_position(pos: Vector2):
	player.global_position = pos

func activate_camera_transistion():
	if camera:
		camera.global_position = cam_pos.global_position

func _on_boundary_entered(body: Node2D) -> void:
	print_debug(str("Room activated: ", self.name))
	if body.is_in_group("Player"):
		activate_camera_transistion()
		player.reset()
