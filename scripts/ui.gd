extends CanvasLayer

@export var animation_player: AnimationPlayer
@export var death_label: Label
var player: CharacterBody2D
var deaths: int = 0

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)

func _on_player_died():
	deaths =  deaths + 1
	animation_player.play("transition_out")
	await animation_player.animation_finished
	animation_player.play("transition_in")
	death_label.text = "Deaths: " + str(deaths)
