extends Node2D

@onready var slots = $slots
@export var lista_comandas = [0, 0, 0, 0, 0]
var slots_array = null

# Called when the node enters the scene tree for the first time.
func _ready():
	slots_array = slots.get_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
