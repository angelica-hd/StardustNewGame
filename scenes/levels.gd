extends Node2D
@onready var level_container = $levelcontainer
@onready var victory_menu = $"Victoria-menu"
@export var levels : Array[PackedScene] = []
var current_level = -1 
func _ready():
	if is_multiplayer_authority():
			cargarNivel()
			victory_menu.all_ready.connect(cargarNivel)

func cargarNivel():
	victory_menu.visible = false
	current_level += 1
	for child in level_container.get_children():
		child.queue_free()
	var level = levels[current_level].instantiate()
	level_container.add_child(level, true)
	level.level_ended.connect(level_en)

func level_en():
	victory_menu.visible = true

