class_name Main2
extends Node2D

@onready var metaFlecha = $Tutorial/meta
@onready var tiempoFlecha = $Tutorial/tiempo
@onready var ingredientes = $Tutorial/ingredientes
@onready var ingredientes_2 = $Tutorial/ingredientes2
@onready var ingredientes_3 = $Tutorial/ingredientes3
@onready var comanda = $Tutorial/comanda

@onready var tutorial = $Tutorial
var moved = false
var atendido = false
var reglas = false
var t0 = 0
@onready var reglastuto = $Tutorial/Reglas/MarginContainer/VBoxContainer/Label

var role = null
@onready var music = $AudioStreamPlayer2D

@export var mesero_scene: PackedScene
@export var chef_scene : PackedScene
@onready var players: Node2D = $Players
@onready var spawn: Node2D = $Spawn
@onready var meta = $Meta/meta
@export var meta_dia = 50
@onready var countdown = $countdown 
var ganancias = 0
@onready var mesa_ing = $mesaIng
@export var sec = 0
@onready var timer_cliente = $TimerCliente
signal level_ended
var max_clientes_fila = 5
@export var max_clientes_dia = 0

var packed_cliente = preload("res://scenes/cliente.tscn")

@onready var tocomple = mesa_ing.get_tocomple()[0]
signal losed_level
func timer_process(delta):
	if sec > 0:
		sec -=0.1
	else:
		var clientes_fila = get_tree().get_nodes_in_group("clientes")
		if max_clientes_fila > 0  and max_clientes_dia > 0:
			var new_client = packed_cliente.instantiate()
			var pos = spawn.get_child(2).global_position
			add_child(new_client, true)
			new_client.global_position = pos
			max_clientes_fila-=1
			max_clientes_dia-=1
			sec = 10

func _on_timer_cliente_timeout():
	pass
	
func _ready() -> void:
	var id = multiplayer.get_unique_id()
	role = Game.get_player(id).role
	countdown.get_node("UI/Control").minutes = 1
	countdown.get_node("UI/Control").seconds = 30
	Game.main = self
	Game.players.sort_custom(func (a, b): return a.id < b.id)
	for i in Game.players.size():
		var player_data = Game.players[i]
		
		if player_data.role == 1:
			var player = chef_scene.instantiate()
			players.add_child(player)
			player.setup(player_data)
			player.global_position = spawn.get_child(0).global_position
		elif player_data.role == 2:
			var player = mesero_scene.instantiate()
			players.add_child(player)
			player.setup(player_data)
			player.global_position = spawn.get_child(1).global_position

@rpc("call_local", "reliable", "any_peer")
func send_pago(valor):
	ganancias+=valor
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	meta.text = "$"+str(ganancias)+" / $"+str(meta_dia)
	var t = countdown.get_child(0).get_child(0)
	var tutos = tutorial.get_children()
	timer_process(delta)
	var level = get_parent().get_parent().current_level
#	if tocomple.come == true:
#		ganancias = 50
	if t.minutes == 0 and t.seconds == 0:
		level = -2
		tutos[0].visible = false
		tutos[1].visible = false
		tutos[2].visible = false
		comanda.visible = false
		ingredientes.visible = false
		ingredientes_2.visible = false
		ingredientes_3.visible = false
		t0 = 240
		if ganancias < meta_dia:
			music.stop()
			losed_level.emit()
		else:
			music.stop()
			level_ended.emit()
				
	# arreglo con los clientes en el nivel
	var clientes_fila = get_tree().get_nodes_in_group("clientes")
	
	Game.arr_clientes = clientes_fila
	

	if level == 0 or level == -1:
		if Input.is_action_pressed("left_click") and moved == false:
			tutos[0].visible = false
			moved = true
		if role == 2:
			if moved == true and atendido == false:
				tutos[1].visible = true
				
			if Input.is_action_pressed("right_click"):
				tutos[1].visible = false
				atendido = true
				
			if atendido == true:
				t0 += delta
				tutos[2].visible = true
				if t0 < 6:
					metaFlecha.visible = true
					tiempoFlecha.visible = true
					reglastuto.text = "Cada día tiene una duración límite y también
										una meta en ganancias que cumplir"
				elif t0 < 12:
					metaFlecha.visible = false
					tiempoFlecha.visible = false
					reglastuto.text = "Toma los pedidos de los clientes en la mesa
										para que el chef pueda prepararlos"
				elif t0 < 18:
					reglastuto.text = "Acércate al mesón para tomar el pedido listo
										y entrégaselo al cliente correspondiente"
				elif t0 < 24:
					reglastuto.text = "Atiende la mayor cantidad de clientes
										antes de que se enojen!"
				else:
					t0 = 6
		elif role == 1:
			if moved == true:
				t0 += delta
				if t0 < 6:
					tutos[2].visible = true
					metaFlecha.visible = true
					tiempoFlecha.visible = true
				elif t0 < 12:
					metaFlecha.visible = false
					tiempoFlecha.visible = false
					reglastuto.text = "Cada vez que el mesero tome un pedido, se
										creará una comanda en tu pantalla"
					comanda.visible = true
				elif t0 < 18:
					reglastuto.text = "Guíate de la comanda para armar el completo 
										haciendo CLICK en los ingredientes a tu derecha"
					comanda.visible = false
					ingredientes.visible = true
					ingredientes_2.visible = true
					ingredientes_3.visible = true
				elif t0 < 24:
					reglastuto.text = "Una vez armado el pedido déjalo en el mesón del 
										centro para que el mesero pueda entregarlo"
					comanda.visible = false
					ingredientes.visible = false
					ingredientes_2.visible = false
					ingredientes_3.visible = false
				elif t0 < 30:
					reglastuto.text = "Prepara los pedidos lo más rápido posible
										antes de que los clientes se enojen!"
					comanda.visible = false
					ingredientes.visible = false
					ingredientes_2.visible = false
					ingredientes_3.visible = false
				else:
					t0 = 12
