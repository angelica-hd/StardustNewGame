class_name Tomate
extends Node2D

@onready var area_2dd = $Area2D
var selected = false

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
		
@rpc("call_local","reliable","any_peer")
func pick_up(role):
	for player in Game.players:
		if player.role == role:
			var tocomple = player.scene.has_tocomple
			if tocomple != null and tocomple.get_parent() is Player:
				if not tocomple.has_tomate:
					var parent = get_parent()
					parent.remove_child(self)
					tocomple.add_child(self)
					tocomple.has_tomate = self
					position = Vector2.ZERO 

func _on_player_entered(body):
	var player = body as Player
	#if is_multiplayer_authority():
	if player:#revisar, por esto es que funciona raro el mesón con mesero y chef
		if selected and player.role == 1:
			pick_up.rpc(player.role)
			selected = false
