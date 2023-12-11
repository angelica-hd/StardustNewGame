extends MarginContainer

@onready var m_menu = $PanelContainer/MarginContainer/VBoxContainer/m_menu
@onready var exit = $PanelContainer/MarginContainer/VBoxContainer/exit
@onready var retry = $PanelContainer/MarginContainer/VBoxContainer/retry
var host_ready = false
var client_ready = false
signal losed
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	m_menu.pressed.connect(_on_menu)
	exit.pressed.connect(_on_exit)
	retry.pressed.connect(_on_retry)
func _on_menu():
	_disconnect()
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")
@rpc("any_peer")
func send_ready_signal():
	client_ready = true
func _on_retry():
	if is_multiplayer_authority():
		host_ready = true
		check_both_ready()
	else:
		send_ready_signal.rpc()
func check_both_ready():
	if host_ready and client_ready:
		losed.emit()
		host_ready = false
		client_ready = false	
func _disconnect():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	Game.players = []
func _on_exit():
	Game.exit_game.rpc()
