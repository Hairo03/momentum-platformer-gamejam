class_name Room
extends Node2D

@export_group("Room Settings")
@export var room_id: String = "room_1_1"
@export var boundary_shape: CollisionShape2D

@export_group("Checkpoints")
@export var left: Node2D
@export var right: Node2D

var player: CharacterBody2D = null
var is_active: bool = false
@onready var camera = get_viewport().get_camera_2d()

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func set_player_position(pos: Vector2):
	player.global_position = pos

func activate_camera_transistion():
	if not camera or not boundary_shape:
		return
	
	var shape_rect = boundary_shape.shape.get_rect()
	var shape_pos = boundary_shape.global_position
	
	camera.limit_smoothed = true
	camera.limit_left = int(shape_pos.x + shape_rect.position.x)
	camera.limit_right = int(shape_pos.x + shape_rect.end.x)
	camera.limit_top = int(shape_pos.y + shape_rect.position.y + 13) # MAGIC NUMBERS BAD!! :(
	camera.limit_bottom = int(shape_pos.y + shape_rect.end.y - 21) # Camera offset adjustment
	print_debug(str("Camera limits set to: L:", camera.limit_left, " R:", camera.limit_right, " T:", camera.limit_top, " B:", camera.limit_bottom))

func _on_boundary_entered(body: Node2D) -> void:
	print_debug(str("Room activated: ", self.name))
	if body.is_in_group("Player"):
		var nearest_checkpoint: Node2D
		var dist_to_left := body.global_position.distance_to(left.global_position)
		var dist_to_right := body.global_position.distance_to(right.global_position)
		if dist_to_left < dist_to_right:
			nearest_checkpoint = left
		else:
			nearest_checkpoint = right
		
		set_player_position(nearest_checkpoint.global_position)
		activate_camera_transistion()
		player.reset()
