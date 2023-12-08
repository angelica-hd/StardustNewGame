class_name Cliente
extends Node2D

@onready var pensamiento = $pensamiento
@onready var markp = $markp
@onready var area_2d = $Area2D
@onready var animation_player = $AnimationPlayer

signal dropped

var dropped_in_mesilla = false
var selected = false
var atendido_fila =  false
var atendido_mesa = false
var me_jui = false

var pago = 0

func _on_area_2d_input_event(viewport, event, shape_idx):
	if is_multiplayer_authority():
		if !Input.is_action_pressed("right_click"):
			if selected:
				selected = false
				send_position.rpc(position)
				dropped.emit()
#				if atendido_mesa 
				send_gan.rpc()
				if atendido_fila:
					send_pensamiento.rpc()
		else:
			selected = true

@rpc("call_local", "authority", "reliable")
func send_position(pos):
	position = pos

@rpc("call_local", "reliable", "any_peer")
func send_gan(drop = false):
	if drop:
		dropped_in_mesilla = true
	# solo si se encuentra en una mesilla, sino no
	if dropped_in_mesilla:
		atendido_fila = true
		animation_player.stop()
		
@rpc("call_local", "reliable", "any_peer")
func send_atendido_mesa():
	atendido_mesa = true

@rpc("call_local", "authority", "reliable")
func send_pensamiento():
	pensamiento.visible = true
	
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("alien")
	pensamiento.hide()
	var id = multiplayer.get_unique_id()
	var player = Game.get_player(id)
	var role = player.role
	Debug.dprint(role)
	if role == 1:
		get_node("Area2D/CollisionShape2D").disabled = true
	for p in Game.players:
		if p.role == 2:
			set_multiplayer_authority(p.id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

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
