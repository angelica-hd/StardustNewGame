class_name Player
extends CharacterBody2D

@export var speed = 400
@onready var pause_menu = $CanvasLayer/Pause_Menu

var target = position
var role
@onready var ocupao = false

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc_id(1)
			
func _physics_process(delta):
	if is_multiplayer_authority():
		if Input.is_action_pressed("left_click"):
			target = get_global_mouse_position() 
			velocity = position.direction_to(target) * speed
		if position.distance_to(target) > 10:
			move_and_slide()
		
func setup(player_data: Statics.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)
	pause_menu.set_multiplayer_authority(player_data.id)
	role = player_data.role
	for i in Game.players.size():
		if Game.players[i].role == player_data.role:
			Game.players[i].scene = self
			break
	
@rpc
func test():
#	if is_multiplayer_authority():
	#Debug.dprint("test - player: %s" % name, 30)
	pass
