extends CanvasLayer

var total_deaths: int = 0
@onready var deaths_label: Label = $CenterContainer/VBoxContainer/DeathsLabel

func _init(deaths: int) -> void:
	total_deaths = deaths

func _ready() -> void:
	deaths_label.text = str("Total deaths: ", total_deaths)
