extends MarginContainer

@onready var resume = $VBoxContainer/resume
@onready var menu_p = $VBoxContainer/Menu_p
@onready var quit = $VBoxContainer/quit

func _ready():
	hide()
	resume.pressed.connect(_on_resume_pressed)
	#retry.pressed.connect(_on_retry_pressed)
	menu_p.pressed.connect(_on_main_menu_pressed)
	quit.pressed.connect(_on_quit_pressed)
	Game.paused.connect(_on_game_paused)

func _input(event):
	if is_multiplayer_authority():
		if event.is_action_pressed("pause"):
			Game.pause.rpc(!get_tree().paused)
			
func _on_resume_pressed():
	Game.pause.rpc(false)
	
func _on_quit_pressed():
	Game.exit_game.rpc()
	
	
func _on_main_menu_pressed():
	Game.pause.rpc(false)
	_disconnect()
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")

func _on_game_paused():
	visible = get_tree().paused
	
func _disconnect():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	Game.players = []
	
