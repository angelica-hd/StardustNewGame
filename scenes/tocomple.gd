class_name Tocomple
extends Node2D

@onready var area_2dd = $Area2D
var selected = false
var come = false
# Called when the node enters the scene tree for the first time.
func _ready():
	area_2dd.body_entered.connect(_on_player_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("left_click"):
		selected = true
		var bodies = area_2dd.get_overlapping_bodies()
		for body in bodies:
			_on_player_entered(body)
		
@rpc("call_local", "reliable")
func send_come():
	come = true

@rpc("call_local","reliable","any_peer")
func pick_up(role):
	for player in Game.players:
		if player.role == role:
			Debug.dprint(player.scene.has_tocomple)
			if player.scene.has_tocomple == false:
				var parent = get_parent()
				parent.remove_child(self) # se hace lo que teníamos
				player.scene.add_child(self)
				player.scene.set_has_tocomple(true)# el jugador ya tiene un tocomple
				position = Vector2.ZERO 
				if parent is Marker2D:
					var meson = parent.get_parent().get_parent()
					var slots = parent.get_parent().get_children()
					var index = slots.find(parent, 0)
					meson.meson_elements[index] = 0
			
func _on_player_entered(body):
	var player = body as Player
	var client = body as Cliente
	#if is_multiplayer_authority():
	if player:#revisar, por esto es que funciona raro el mesón con mesero y chef
		#if player.ocupao == false:
			#var new_parent = player.get_node(player.get_path())
			#player.ocupao = true
			#Debug.dprint("hola")
		if selected:
			# si hay 0 tocomples en el player
			pick_up.rpc(player.role)
	if client:
		var new_parent2 = client.get_node(client.get_path())
		#Debug.dprint("hello")
		if selected:
			# si el cliente fue atendido en la fila pero aun no en la msea
			if client.atendido_fila == true and client.atendido_mesa == false: 
				if get_parent() is Player:
					get_parent().set_has_tocomple(false)
				get_parent().remove_child(self)
				new_parent2.add_child(self)
				position = Vector2.ZERO
				send_come.rpc()
				
				client.atendido_mesa = true
				#ganancias += 50
				#get_tree().change_scene_to_file("res://scenes/Victoria-menu.tscn")
