extends Node

enum FacingDirection {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

var crop_tiles_atlas_coords_map = {
	Item.ItemName["CAULIFLOWER"]: [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)],
	Item.ItemName["CARROT"]: [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],
	Item.ItemName["TOMATO"]: [Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4)],
	Item.ItemName["EGGPLANT"]: [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5)],
	Item.ItemName["TULIP"]: [Vector2i(0, 6), Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6)],
	Item.ItemName["LETTUCE"]: [Vector2i(0, 7), Vector2i(1, 7), Vector2i(2, 7), Vector2i(3, 7)],
	Item.ItemName["TURNIP"]: [Vector2i(0, 10), Vector2i(1, 10), Vector2i(2, 10), Vector2i(3, 10)],
	Item.ItemName["WHEAT"]: [Vector2i(0, 8), Vector2i(1, 8), Vector2i(2, 8), Vector2i(3, 8)],
	Item.ItemName["PUMPKIN"]: [Vector2i(0, 9), Vector2i(1, 9), Vector2i(2, 9), Vector2i(3, 9)],
	Item.ItemName["DAHLIA"]: [Vector2i(0, 11), Vector2i(1, 11), Vector2i(2, 11), Vector2i(3, 11)],
	Item.ItemName["BEETROOT"]: [Vector2i(0, 12), Vector2i(1, 12), Vector2i(2, 12), Vector2i(3, 12)],
	Item.ItemName["STARFRUIT"]: [Vector2i(0, 13), Vector2i(1, 13), Vector2i(2, 13), Vector2i(3, 13)],
	Item.ItemName["CUCUMBER"]: [Vector2i(0, 14), Vector2i(1, 14), Vector2i(2, 14), Vector2i(3, 14)],
}

const SOIL_TILES_SOURCE_ID = 15
const CROP_TILES_SOURCE_ID = 23
const GRASS_TILES_SOURED_ID = 11
const SOIL_TERRAIN = 17
const GROUND_LAYER = 0
const HIGH_ELEVATION_LAYER = 1
const SOIL_LAYER = 2
const CROP_LAYER = 3
const PATH_LAYER = 4
const FLORA_LAYER = 4
const DECORATION_LAYER = 6

var current_tool = Item.ItemName.HOE
var tools: Array = [Item.ItemName.HOE, Item.ItemName.AXE, Item.ItemName.WATERING_CAN]
var tool_index = 0
var last_direction = FacingDirection.DOWN
var soil_tiles = []
var crop_tiles: Dictionary = {}
var tile_map_node: Node = null
var player_node: Node = null

signal tool_index_updated
signal hotbar_index_updated
signal inventory_updated
signal inventory_index_updated
signal inventory_open_updated
signal wallet_updated

@onready var inventory_slot_scene = preload("res://Scenes/Inventory_Slot.tscn")

var hotbar = {}
var hotbar_index = 0;
var inventory: Dictionary = {}
var inventory_index = 0;
var inventory_open = false

var wallet := 25

var in_shop_range = false
var shop_open = false

var player_ground_level = 0

const MAX_ITEM_STACK = 10

func _ready():
	# Instantiate inventory with 27 empty slots
	for i in range(27):
		inventory[i] = null
	# Instantiate hotbar with 5 empty slots
	for i in range(7):
		hotbar[i] = null
		
func get_current_tool():
	return tools[tool_index]
	
func add_item(item, to_hotbar = false):
	var added_to_hotbar = false
	
	# Add to hotbar
	if to_hotbar:
		added_to_hotbar = add_item_to_hotbar(item)
		inventory_updated.emit()

	# Add to inventory
	if not added_to_hotbar:
		for i in range(inventory.size()):
			if inventory[i] != null and item["item"]["type"] == inventory[i]["item"]["type"] and item["item"]["item_name"] == inventory[i]["item"]["item_name"]:
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

func decrement_item(item):
	for i in range(inventory.size()):
		if inventory[i] != null and item["item"]["type"] == inventory[i]["item"]["type"] and item["item"]["item_name"] == inventory[i]["item"]["item_name"]:
			inventory[i]["quantity"] -= 1
			inventory_updated.emit()
			return true

func remove_item(item):
	for i in range(inventory.size()):
		if inventory[i] == item:
			inventory[i] = null
	inventory_updated.emit()
	
func add_item_to_hotbar(item):
	for i in range(hotbar.size()):
		if hotbar[i] == null:
			hotbar[i] = item
			inventory_updated.emit()
			return true
	return false
	
func remove_item_from_hotbar(item):
	for i in range(hotbar.size()):
		var hotbar_item = hotbar[i]
		if hotbar_item != null and item["type"] == hotbar_item["type"] and item["name"] == hotbar_item["name"]:
			if hotbar_item["quantity"] <= 0:
				hotbar[i] = null
			inventory_updated.emit()
			return true
	return false
	
func unassign_hotbar_item(item):
	for i in range(hotbar.size()):
		var hotbar_item = hotbar[i]
		if hotbar_item != null and item == hotbar_item:
			hotbar[i] = null
			inventory_updated.emit()
			return true
	return false

func is_item_assigned_to_hotbar(item):
	for hotbar_item in hotbar.values():
		if hotbar_item == item:
			return true
	return false

func update_tool_index(index):
	tool_index = index
	tool_index_updated.emit()
	
func update_hotbar_index(index):
	hotbar_index = index
	hotbar_index_updated.emit()
	
func update_inventory_index(index):
	inventory_index = index
	inventory_index_updated.emit()
	
func get_inventory_index_from_node(slot_node: Node):
	var index = slot_node.get_index()
	return index

func toggle_inventory_open():
	inventory_open = !inventory_open
	inventory_open_updated.emit()
	
func set_wallet(amount: int):
	wallet = amount
	wallet_updated.emit()

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
