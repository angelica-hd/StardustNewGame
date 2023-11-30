class_name Main
extends Node2D

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

# @onready var tocomple = $mesaIng/tocomple
#@onready var cliente = $cliente
var packed_cliente = preload("res://scenes/cliente.tscn")

@onready var tocomple = mesa_ing.get_tocomple()[0]

func timer_process(delta):
	if sec > 0:
		sec -=0.1
	else:
		var clientes_fila = get_tree().get_nodes_in_group("clientes")
		if len(clientes_fila) < 5:
			var new_client = packed_cliente.instantiate()
			var pos = spawn.get_child(2).global_position
			add_child(new_client, true)
			new_client.global_position = pos
			sec = 10

func _on_timer_cliente_timeout():
	pass
	
func _ready() -> void:
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
	
	timer_process(delta)
#	if tocomple.come == true:
#		ganancias = 50
	if t.minutes == 0 and t.seconds == 0:
			if ganancias < meta_dia:
				get_tree().change_scene_to_file("res://scenes/perder_menu.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/Victoria-menu.tscn")
	
	# arreglo con los clientes en el nivel
	var clientes_fila = get_tree().get_nodes_in_group("clientes")
	
	# sumar los pagos de cada uno de los clientes
	# (aun no funciona bien)
#	for cliente in clientes_fila:
#		if cliente.atendido_mesa:
#			var monto = cliente.get_pago_cliente()
#			if monto > 0:
#				ganancias += monto
#				cliente.reset_pago_cliente.rpc()
