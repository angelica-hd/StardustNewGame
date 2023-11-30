extends Player

var drag = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(player_data: Statics.PlayerData):
	super.setup(player_data)
	if not is_multiplayer_authority():
		collision_layer = 0
		collision_mask = 0
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
