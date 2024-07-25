extends Node

enum Tools {
	HOE,
	AXE,
	SHOVEL,
}

enum FacingDirection {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

enum ItemTypes {
	SEED,
	CROP,
}

enum ItemNames {
	CAULIFLOWER,
	#CORN,
	CARROT,
	TOMATO,
	EGGPLANT,
	TULIP,
	LETTUCE,
	TURNIP,
	WHEAT,
	PUMPKIN,
	DAHLIA,
	BEETROOT,
	STARFRUIT,
	CUCUMBER,
}

var item_type_map = {
	ItemTypes.SEED: "seed",
	ItemTypes.CROP: "crop",
}

var item_name_map = {
	ItemNames.CAULIFLOWER: "cauliflower",
	#ItemNames.CORN: "corn",
	ItemNames.CARROT: "carrot",
	ItemNames.TOMATO: "tomato",
	ItemNames.EGGPLANT: "eggplant",
	ItemNames.TULIP: "tulip",
	ItemNames.LETTUCE: "lettuce",
	ItemNames.TURNIP: "turnip",
	ItemNames.WHEAT: "wheat",
	ItemNames.PUMPKIN: "pumpkin",
	ItemNames.DAHLIA: "dahlia",
	ItemNames.BEETROOT: "beetroot",
	ItemNames.STARFRUIT: "starfruit",
	ItemNames.CUCUMBER: "cucumber",
}

var item_reigons = {
	ItemNames.CAULIFLOWER: {
		ItemTypes.SEED: Rect2(0, 48, 16, 16),
		ItemTypes.CROP: Rect2(16, 48, 16, 16),
	},
	#ItemNames.CORN: {
		#ItemTypes.SEED: Rect2(0, 16, 16, 16),
		#ItemTypes.CROP: Rect2(16, 16, 16, 16),
	#},
	ItemNames.CARROT: {
		ItemTypes.SEED: Rect2(0, 32, 16, 16),
		ItemTypes.CROP: Rect2(16, 32, 16, 16),
	},
	ItemNames.TOMATO: {
		ItemTypes.SEED: Rect2(0, 64, 16, 16),
		ItemTypes.CROP: Rect2(16, 64, 16, 16),
	},
	ItemNames.EGGPLANT: {
		ItemTypes.SEED: Rect2(0, 80, 16, 16),
		ItemTypes.CROP: Rect2(16, 80, 16, 16),
	},
	ItemNames.TULIP: {
		ItemTypes.SEED: Rect2(0, 96, 16, 16),
		ItemTypes.CROP: Rect2(16, 96, 16, 16),
	},
	ItemNames.LETTUCE: {
		ItemTypes.SEED: Rect2(0, 112, 16, 16),
		ItemTypes.CROP: Rect2(16, 112, 16, 16),
	},
	ItemNames.TURNIP: {
		ItemTypes.SEED: Rect2(0, 160, 16, 16),
		ItemTypes.CROP: Rect2(16, 160, 16, 16),
	},
	ItemNames.WHEAT: {
		ItemTypes.SEED: Rect2(0, 128, 16, 16),
		ItemTypes.CROP: Rect2(16, 128, 16, 16),
	},
	ItemNames.PUMPKIN: {
		ItemTypes.SEED: Rect2(0, 144, 16, 16),
		ItemTypes.CROP: Rect2(16, 144, 16, 16),
	},
	ItemNames.DAHLIA: {
		ItemTypes.SEED: Rect2(0, 176, 16, 16),
		ItemTypes.CROP: Rect2(16, 176, 16, 16),
	},
	ItemNames.BEETROOT: {
		ItemTypes.SEED: Rect2(0, 192, 16, 16),
		ItemTypes.CROP: Rect2(16, 192, 16, 16),
	},
	ItemNames.STARFRUIT: {
		ItemTypes.SEED: Rect2(0, 208, 16, 16),
		ItemTypes.CROP: Rect2(16, 208, 16, 16),
	},
	ItemNames.CUCUMBER: {
		ItemTypes.SEED: Rect2(0, 224, 16, 16),
		ItemTypes.CROP: Rect2(16, 224, 16, 16),
	},
}

var crop_tiles_atlas_coords_map = {
	"cauliflower": [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)],
	#"corn": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1)],
	"carrot": [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],
	"tomato": [Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4)],
	"eggplant": [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5)],
	"tulip": [Vector2i(0, 6), Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6)],
	"lettuce": [Vector2i(0, 7), Vector2i(1, 7), Vector2i(2, 7), Vector2i(3, 7)],
	"turnip": [Vector2i(0, 10), Vector2i(1, 10), Vector2i(2, 10), Vector2i(3, 10)],
	"wheat": [Vector2i(0, 8), Vector2i(1, 8), Vector2i(2, 8), Vector2i(3, 8)],
	"pumpkin": [Vector2i(0, 9), Vector2i(1, 9), Vector2i(2, 9), Vector2i(3, 9)],
	"dahlia": [Vector2i(0, 11), Vector2i(1, 11), Vector2i(2, 11), Vector2i(3, 11)],
	"beetroot": [Vector2i(0, 12), Vector2i(1, 12), Vector2i(2, 12), Vector2i(3, 12)],
	"starfruit": [Vector2i(0, 13), Vector2i(1, 13), Vector2i(2, 13), Vector2i(3, 13)],
	"cucumber": [Vector2i(0, 14), Vector2i(1, 14), Vector2i(2, 14), Vector2i(3, 14)],
}

const SOIL_TILES_SOURCE_ID = 15
const CROP_TILES_SOURCE_ID = 23
const GRASS_TILES_SOURED_ID = 11
const GROUND_LAYER = 1
const SOIL_LAYER = 2
const CROP_LAYER = 3
const SOIL_TERRAIN = 17

var current_tool: Tools = Tools.HOE
var last_direction = FacingDirection.DOWN
var soil_tiles = []
var crop_tiles: Dictionary = {}
var tile_map_node: Node = null
var player_node: Node = null

signal inventory_updated
signal inventory_index_updated
signal inventory_open_updated

@onready var inventory_slot_scene = preload("res://Scenes/Inventory_Slot.tscn")

var inventory = {}
var inventory_index = 0;
var inventory_open = false

func _ready():
	# Instantiate inventory with 27 empty slots
	for i in range(27):
		inventory[i] = null
	
func add_item(item):
	for i in range(inventory.size()):
		if inventory[i] != null and item["type"] == inventory[i]["type"] and item["name"] == inventory[i]["name"]:
			inventory[i]["quantity"] += item["quantity"]
			inventory_updated.emit()
			update_inventory_index(inventory_index)
			return true
		elif inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()
			update_inventory_index(inventory_index)
			return true
	return false
			
	
func remove_item():
	inventory_updated.emit()	
	pass
	
	
func update_inventory_index(index):
	inventory_index = index
	inventory_index_updated.emit()

func toggle_inventory_open():
	inventory_open = !inventory_open
	inventory_open_updated.emit()

func set_tile_map(node: Node):
	tile_map_node = node

func update_direction(direction: FacingDirection):
	last_direction = direction

func update_soil_tiles(new_soil_tiles: Array):
	soil_tiles = new_soil_tiles

func set_player_node(node: Node):
	player_node = node

func repaint_soil_tiles():
	tile_map_node.clear_layer(SOIL_LAYER)
	tile_map_node.set_cells_terrain_connect(SOIL_LAYER, Global.soil_tiles, SOIL_TERRAIN, 0)

func repaint_crop_tiles():
	tile_map_node.clear_layer(CROP_LAYER)
	for position in crop_tiles.keys():
		var crop = crop_tiles[position]
		tile_map_node.set_cell(CROP_LAYER, position, CROP_TILES_SOURCE_ID, crop.atlas_coords)
