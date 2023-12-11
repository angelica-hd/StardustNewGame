extends Node2D

@onready var area_2d = $Area2D
@onready var silla = $silla
@onready var silla_2 = $silla2

# variable que indica si hay un cliente en la mesilla
var hay_cliente = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for p in Game.players:
		if p.role == 2:
			set_multiplayer_authority(p.id)
	if is_multiplayer_authority():
		area_2d.body_entered.connect(_on_body_entered)
		area_2d.body_exited.connect(_on_body_exited)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_exited(body):
	var cliente = body as Cliente
	if cliente:
		cliente.dropped.disconnect(is_dropped)
		# si el cliente que está saliendo ya fue atendido en la fila
		if cliente.atendido_fila:
			# se cambia la flag a false
			hay_cliente = false
		
	
func _on_body_entered(body):
	var cliente = body as Cliente
	if cliente and !hay_cliente:
		cliente.dropped.connect(is_dropped.bind(cliente))
		cliente.send_gan.rpc(true, hay_cliente)
		# si se dejó un cliente en la mesilla, la flag cambia a TRUE
		hay_cliente = true
		#cliente.set_dropped_in_mesilla(true)
		
		
		
#crear señal al cliente para verificar si se fue y desocupar silla
func is_dropped(cliente):
	#falta verificar sillas ocupadas o no 
	cliente.send_position.rpc(silla.global_position)
