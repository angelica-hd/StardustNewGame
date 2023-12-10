class_name Basurero
extends StaticBody2D


@onready var area_2d = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	area_2d.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	var player = body as Player
	if player:
		var completo = player.has_tocomple
		if completo:
			multi_queue_free.rpc(completo.get_path())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# para rcpear el queue_free
@rpc("call_local","any_peer","reliable")
func multi_queue_free(path):
	var body = get_node(path)
	body.get_parent().has_tocomple = null
	body.get_parent().remove_child(body)
