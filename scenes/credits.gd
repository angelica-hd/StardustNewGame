extends MarginContainer

@onready var back = $PanelContainer5/back


# Called when the node enters the scene tree for the first time.
func _ready():
	back.pressed.connect(_on_back)


func _on_back():
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")
	
