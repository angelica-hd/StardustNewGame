extends StaticBody2D

var packed_tocomple = preload("res://scenes/tocomple.tscn")
var packed_tomate = preload("res://scenes/tomate.tscn")
var packed_palta = preload("res://scenes/palta.tscn")
@onready var completospawn = $completospawn
@onready var tomatespawn = $tomatespawn
@onready var paltasspawn = $paltasspawn
@onready var tocomple = $tocomple

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_tocomple():
	#return tocomple
	return get_tree().get_nodes_in_group("tocomples")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var hay_tocomple = get_node("tocomple")
	var hay_tomate = get_node("tomate")
	var hay_palta = get_node("palta")
	#var hay_tocomple = get_node_or_null("res://scenes/tocomple.tscn")
	if hay_tocomple == null:
		var new_tocomple = packed_tocomple.instantiate()
		add_child(new_tocomple)
		new_tocomple.global_position = completospawn.global_position
	if hay_tomate == null:
		var new_tomate = packed_tomate.instantiate()
		add_child(new_tomate)
		new_tomate.global_position = tomatespawn.global_position
	if hay_palta == null:
		var new_palta = packed_palta.instantiate()
		add_child(new_palta)
		new_palta.global_position = paltasspawn.global_position
