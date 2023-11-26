class_name Meson
extends StaticBody2D

@onready var area_2d = $Area2D
var selected = false
@onready var slots = $slots
@export var meson_elements = [0, 0, 0, 0]


# Called when the node enters the scene tree for the first time.
func _ready():
	area_2d.body_entered.connect(_on_player_entered)
	pass # Replace with function body.
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("left_click"):
		selected = true

@rpc("call_local", "reliable", "any_peer")
func drop_completo(path):
	var slots_array = slots.get_children()
	var tocomple = get_node(path)
	var index = meson_elements.find(0,0)
	if index != -1:
		var s = slots_array[index]
		meson_elements[index] = 1
		if tocomple.get_parent() is Player:
			tocomple.get_parent().has_tocomple = null
		tocomple.get_parent().remove_child(tocomple)
		s.add_child(tocomple)
		tocomple.position = Vector2.ZERO
	
func _on_player_entered(body):
	var player = body as Player
	#if is_multiplayer_authority():
	if player:
		var tocomple = player.has_tocomple
		#Debug.dprint(self)
		if selected:
			if tocomple != null:
				drop_completo.rpc(tocomple.get_path())
				#player.ocupao = false
				selected = false
			else:
				selected = false
				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
