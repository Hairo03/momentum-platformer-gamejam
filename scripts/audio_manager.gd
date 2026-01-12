extends Node2D

var sounds: Array[AudioStreamPlayer] = []
var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	player.jump.connect(_on_player_jump)
	player.died.connect(_on_player_died)
	player.walk.connect(_on_player_walk)
	player.ability.connect(_on_player_ability)
	player.charge.connect(_on_player_charge)
	
	for node in get_children():
		sounds.append(node)

func _on_player_jump():
	_play_sound("Jump")

func _on_player_died():
	_play_sound("Hurt")

func _on_player_walk():
	_play_sound("Footsteps")

func _on_player_ability():
	_play_sound("Ability")

func _on_player_charge():
	_play_sound("Charge")

func _play_sound(sound_name: String):
	var filtered_sounds := sounds.filter(func(item): return item if item.name == sound_name else null )
	var stream: AudioStreamPlayer = filtered_sounds.get(0)
	stream.play()
