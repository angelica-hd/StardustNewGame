extends MarginContainer
@onready var m_menu = $PanelContainer/MarginContainer/VBoxContainer/m_menu
@onready var exit = $PanelContainer/MarginContainer/VBoxContainer/exit
func _ready():
	hide()
	m_menu.pressed.connect(_on_menu)
	exit.pressed.connect(_on_exit)
	
func _on_menu():
	_disconnect()
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")

func _on_exit():
	Game.exit_game.rpc()
	
func _disconnect():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	Game.players = []
