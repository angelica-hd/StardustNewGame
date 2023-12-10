extends Sprite2D


@export var Texture_variations : Array = [
	preload("res://assets/clients/Sprite1.png"),
	preload("res://assets/clients/Sprite2.png"),
	preload("res://assets/clients/Sprite3.png"),
	preload("res://assets/clients/Sprite4.png"),
	preload("res://assets/clients/Sprite5.png")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	variate_texture()

func variate_texture():
	if not is_multiplayer_authority():
		if Texture_variations.size() > 1:
			var texture_id: int = randi() % Texture_variations.size()
			var chosen_texture: Texture = Texture_variations[texture_id]
			texture = chosen_texture
			send_texture_id.rpc(texture_id)

@rpc("call_local","reliable","any_peer")
func send_texture_id(id):
	var chosen_texture: Texture = Texture_variations[id]
	texture = chosen_texture
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
