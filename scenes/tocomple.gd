class_name Tocomple
extends Node2D


@onready var sprite_2d = $Area2D/Sprite2D
@onready var area_2dd = $Area2D
var selected = false
var come = false

#Ingredientes:
var has_tomate = null
var has_palta = null

var tipo_completo = "hotdog"

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
			#Debug.dprint(player.scene.has_tocomple)
			if not player.scene.has_tocomple:
				var parent = get_parent()
				parent.remove_child(self) # se hace lo que teníamos
				player.scene.add_child(self)
				player.scene.has_tocomple = self
				#player.scene.set_has_tocomple(true)# el jugador ya tiene un tocomple
				position = Vector2.ZERO 
				if parent is Marker2D:
					var meson = parent.get_parent().get_parent()
					var slots = parent.get_parent().get_children()
					var index = slots.find(parent, 0)
					meson.meson_elements[index] = 0
					
@rpc("call_local","reliable","any_peer")
func client_pick_up(client):
	client = get_tree().root.get_node(client)
	if client.atendido_fila == true and client.atendido_mesa == false and client.pedido_tomado == true: 
		if client.pedido == tipo_completo:
			if get_parent() is Player:
				get_parent().has_tocomple = null
			get_parent().remove_child(self)
			client.add_child(self)
			position = Vector2.ZERO
			if is_multiplayer_authority():
				Game.main.send_pago.rpc(50)
			client.send_atendido_mesa.rpc()

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
			if not (get_parent() is Cliente) or get_parent().atendido_mesa == false:
				pick_up.rpc(player.role)
	if client:
		#var new_parent2 = client.get_node(client.get_path())
		#Debug.dprint("hello")
		if selected:
			client_pick_up.rpc(client.get_path())
			# si el cliente fue atendido en la fila pero aun no en la mesa
			#Debug.dprint(client.atendido_mesa)

