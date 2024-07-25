extends Node2D

@onready var tile_map = %TileMap
@onready var player = %Player

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().root
	# Get the main scene node
	var current_scene = root.get_child(root.get_child_count() - 1)
	for node in current_scene.get_children():
		if node.is_in_group("CollisionObject"):
			for sub_node in node.get_children():
				sub_node.z_index = int(sub_node.position.y)

func _process(delta):
	if Input.is_action_just_pressed("save_game"):
		print("SAVE GAME")
		SaveGameJSON.save()
	if Input.is_action_just_pressed("load_game"):
		print("LOAD GAME")
		SaveGameJSON.load()
