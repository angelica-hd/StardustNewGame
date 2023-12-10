extends Player

@onready var animation_player = $AnimationPlayer
@onready var icon = $Icon

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
	if is_multiplayer_authority():
		if target.x < self.position.x and target.y > self.position.y and velocity != Vector2(0,0):
			icon.flip_h = true
			animation_player.play("caminar")
		elif target.x > self.position.x and target.y < self.position.y and velocity != Vector2(0,0):
			icon.flip_h = false
			animation_player.play("caminar")
		elif target.y < self.position.y and velocity != Vector2(0,0):
			animation_player.play("caminar_arr")
		elif target.y > self.position.y and velocity != Vector2(0,0):
			animation_player.play("caminar_aba")
		else:
			animation_player.play("quieto")

