extends Node2D
@onready var level_container = $levelcontainer
@onready var victory_menu = $"Victoria-menu"
@export var levels : Array[PackedScene] = []
var current_level = -1 
@onready var perder_menu = $"Perder-menu"
@onready var win = $Win

func _ready():
	if is_multiplayer_authority():
		cargarNivel()
		victory_menu.all_ready.connect(cargarNivel)
		perder_menu.losed.connect(Reiniciar)
func Reiniciar():
	perder_menu.visible = false
	current_level = -1 # se pone el nivel inicial 
	cargarNivel()
func cargarNivel():
	victory_menu.visible = false
	current_level += 1
	for child in level_container.get_children():
		child.queue_free()
	Game.arr_clientes = []
	if current_level == 2:
		var level = levels[current_level].instantiate()
		level_container.add_child(level, true)
		win.visible = true
	else:
		var level = levels[current_level].instantiate()
		level_container.add_child(level, true)
		level.level_ended.connect(level_en)
		level.losed_level.connect(level_en2)
func level_en():
	victory_menu.visible = true
func level_en2():
	perder_menu.visible = true



