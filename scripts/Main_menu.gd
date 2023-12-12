extends MarginContainer

@onready var conn = $PanelContainer/MarginContainer/VBoxContainer/Conn
@onready var exit = $PanelContainer/MarginContainer/VBoxContainer/exit
@onready var credits = $PanelContainer/MarginContainer/VBoxContainer/credits


# Called when the node enters the scene tree for the first time.
func _ready():
	conn.grab_focus()
	if Game.multiplayer_test:
		get_tree().change_scene_to_file("res://scenes/lobby_test.tscn")
		return
	conn.pressed.connect(_on_con)
	exit.pressed.connect(_on_exit)
	credits.pressed.connect(_on_credits_pressed)

func _on_con():
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")	
	
func _on_exit():
	Game.exit_game.rpc()
	
func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

