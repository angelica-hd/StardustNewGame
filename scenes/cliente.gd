class_name Cliente
extends Node2D

@export var Texture_variations : Array = [
	preload("res://assets/clients/Sprite1.png"),
	preload("res://assets/clients/Sprite2.png"),
	preload("res://assets/clients/Sprite3.png"),
	preload("res://assets/clients/Sprite4.png"),
	preload("res://assets/clients/Sprite5.png")
]

@onready var esperando = $esperando
@onready var exclamacion = $exclamacion
@onready var markp = $markp
@onready var animation_player = $AnimationPlayer
@onready var area_2d = $Area2D
@onready var icon = $Icon
@onready var gpu_particles_2d = $GPUParticles2D
@onready var collision_shape_2d_2 = $CollisionShape2D2
@onready var collision_shape_2d = $Area2D/CollisionShape2D

# COMANDA COSAS
var opciones_pedido : Array = ["italiano", "palta", "tomate"]
var pedido = 0
var pedido_tomado = false

var index_pedido = null

signal dropped

var dropped_in_mesilla = false
var selected = false
var atendido_fila =  false
var atendido_mesa = false

var pago = 0
var final_position = Vector2.ZERO

# TIMER COSAS
@export var sec = 0
@onready var enojo = $enojo
@onready var timer_enojo = $TimerEnojo
var enojado = false
@onready var feliz = $feliz

# TIMER COSAS
func timer_process(delta):
	if sec > 0:
		sec -=0.01
		if not atendido_fila and sec < 10 and not enojado:
			send_enojo.rpc()
			enojado = true
		elif not pedido_tomado and sec < 10 and not enojado:
			send_enojo.rpc()
			enojado = true
		elif not atendido_mesa and sec < 10 and not enojado:
			send_enojo.rpc()
			enojado = true
		if enojado and sec < 3:
			send_color_enojado.rpc()
			if enojado and sec < 0:
				me_voy_enojado.rpc()
		elif atendido_mesa and sec < 3:
			send_feliz.rpc()
			if sec < 0:
				me_voy_feliz.rpc()

func _on_timer_enojo_timeout():
	pass # Replace with function body.
	
#TEXTURA COSAS
func variate_texture():
	if not is_multiplayer_authority():
		if Texture_variations.size() > 1:
			var texture_id: int = randi() % Texture_variations.size()
			var chosen_texture: Texture = Texture_variations[texture_id]
			#icon.texture = chosen_texture
			send_texture_id.rpc(texture_id)

@rpc("call_local","reliable","any_peer")
func send_texture_id(id):
	var chosen_texture: Texture = Texture_variations[id]
	icon.texture = chosen_texture

@rpc("call_local","any_peer","reliable")
func send_enojo():
	enojo.visible = true
	
@rpc("call_local","any_peer","reliable")
func send_color_enojado():
	self.icon.modulate = Color(0.96,0.2,0.18,1)
	
@rpc("call_local","any_peer","reliable")
func me_voy_enojado():
	gpu_particles_2d.emitting = true
	await get_tree().create_timer(1.0).timeout
	self.queue_free()
	var comandas = get_parent().get_node("comandas")
	if index_pedido != null:
		var old_comanda = comandas.slots_array[index_pedido].get_child(0)
		comandas.slots_array[index_pedido].remove_child(old_comanda)
		comandas.lista_comandas[index_pedido] = 0

@rpc("call_local","any_peer","reliable")
func send_feliz():
	feliz.visible = true
	
@rpc("call_local","any_peer","reliable")
func me_voy_feliz():
	gpu_particles_2d.emitting = true
	await get_tree().create_timer(1.0).timeout
	self.queue_free()
	
#COMANDA COSAS
func generar_pedido():
	if opciones_pedido.size() > 1:
			var pedido_id: int = randi() % opciones_pedido.size()
			var chosen_pedido: String = opciones_pedido[pedido_id]
			pedido = chosen_pedido
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if is_multiplayer_authority():
		if !Input.is_action_pressed("right_click"):
			if selected:
				selected = false
				send_position.rpc(position)
				dropped.emit()
				send_gan.rpc()
				if atendido_fila and not pedido_tomado:
					send_pensamiento.rpc()
		else:
			# si stá presionado el click derecho
			# se revisa si hay alguno seleccionado hasta el momento
			if Game.able_to_be_selected():
				selected = true
			
		#COMANDA COSAS
		var bodies = area_2d.get_overlapping_bodies()
		for body in bodies:
				_on_player_entered(body)

#COMANDA COSAS
func _on_player_entered(body):
	var player = body as Player
	if player and pedido_tomado == false and atendido_fila:
		send_pedido_tomado.rpc()
		send_comanda.rpc(pedido)

@rpc("call_local", "reliable", "any_peer")
func send_comanda(comanda):
	Debug.dprint(comanda)
	var comandas = get_parent().get_node("comandas")
	var index = comandas.lista_comandas.find(0,0)
	index_pedido = index
	pedido = comanda
	if not is_multiplayer_authority():
		var pedido_node = null
		if pedido == "italiano":
			pedido_node = preload("res://scenes/comanda_italiano.tscn").instantiate()
		elif pedido == "tomate":
			pedido_node = preload("res://scenes/comanda_tomate.tscn").instantiate()
		elif pedido == "palta":
			pedido_node = preload("res://scenes/comanda_palta.tscn").instantiate()
		if index != -1:
			comandas.lista_comandas[index] = pedido
			comandas.slots_array[index].add_child(pedido_node)
	
@rpc("call_local", "authority", "reliable")
func send_position(pos):
	position = pos

@rpc("call_local", "reliable", "any_peer")
func send_gan(drop = false, hay_cliente = false):
	if drop and !hay_cliente:
		dropped_in_mesilla = true
	# solo si se encuentra en una mesilla, sino no
	if dropped_in_mesilla:
		atendido_fila = true
		enojado = false
		icon.modulate = Color(1,1,1,1)
		sec = 20
		animation_player.stop()
		# guardamos la posicio final del cliente (en la mesa)
		final_position = global_position

@rpc("call_local", "reliable", "any_peer")
func send_atendido_mesa():
	atendido_mesa = true
	sec = 7
	exclamacion.visible = false
	esperando.visible = false
	enojo.visible = false
	enojado = false
	icon.modulate = Color(1,1,1,1)
	var comandas = get_parent().get_node("comandas")
	if index_pedido != null:
		var old_comanda = comandas.slots_array[index_pedido].get_child(0)
		comandas.slots_array[index_pedido].remove_child(old_comanda)
		comandas.lista_comandas[index_pedido] = 0

@rpc("call_local", "reliable", "any_peer")
func send_pedido_tomado():
	pedido_tomado = true
	enojado = false
	exclamacion.visible = false
	enojo.visible = false
	sec = 20
	icon.modulate = Color(1,1,1,1)
	esperando.visible = true
	
@rpc("call_local", "authority", "reliable")
func send_pensamiento():
	enojo.visible = false
	exclamacion.visible = true
	icon.modulate = Color(1,1,1,1)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	variate_texture()
	gpu_particles_2d.emitting = false
	animation_player.play("alien")
	exclamacion.hide()
	esperando.hide()
	enojo.hide()
	feliz.hide()
	# COMANDA COSAS
	generar_pedido()
	area_2d.body_entered.connect(_on_player_entered)
	var id = multiplayer.get_unique_id()
	var player = Game.get_player(id)
	var role = player.role
	if role == 1:
		get_node("Area2D/CollisionShape2D").disabled = true
	for p in Game.players:
		if p.role == 2:
			set_multiplayer_authority(p.id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if !atendido_fila:
	if selected: # and !atendido_fila:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
			
#	else:
#		global_position = final_position
	
	timer_process(delta)
#	if atendido_mesa:
#		set_pago_cliente.rpc(50)

# para modificar desde fuera el valor de dropped_in_mesilla
func set_dropped_in_mesilla(val):
	dropped_in_mesilla = val

# obtiene el valor de la variable pago
func get_pago_cliente():
	return pago

@rpc("call_local", "reliable", "any_peer")
func set_pago_cliente(valor):
	pago = valor

# vuelve a 0 el valor del pago del cliente
@rpc("call_local", "reliable", "any_peer")
func reset_pago_cliente():
	pago = 0
