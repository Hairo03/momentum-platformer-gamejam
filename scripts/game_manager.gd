extends CanvasLayer

var player: CharacterBody2D
var current_room: String
var current_checkpoint: Vector2
var is_timed_mode: bool = false
var total_deaths := 0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var win_screen: PackedScene

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	

func _process(delta: float) -> void:
	if player:
		if not player.died.is_connected(_on_player_died):
			player.died.connect(_on_player_died)

func start_game():
	is_timed_mode = false
	animation_player.play("transition_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	animation_player.play("transition_in")

func finish_game():
	var win_screen_instance = win_screen.instantiate()
	get_tree().get_root().add_child(win_screen_instance)
	get_tree().paused = true

func start_timed_mode():
	is_timed_mode = true

func set_checkpoint(room_name: String, position: Vector2):
	current_room = room_name
	current_checkpoint = position
	
func respawn_player():
	if player:
		player.global_position = current_checkpoint
		player.reset()

func _on_player_died():
	total_deaths += 1
