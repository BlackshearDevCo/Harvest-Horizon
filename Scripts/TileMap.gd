extends TileMap

@onready var tile_map = %TileMap
@onready var player = %Player
@onready var animated_sprite_2d = %Player/AnimatedSprite2D
@onready var crop_sounds = $"../CropSounds"

@onready var crop_plant_sound = "res://Assests/audio/handleSmallLeather.ogg"
@onready var crop_pickup_sound = "res://Assests/audio/bookFlip3.ogg"

const farming_items_texture: Texture = preload("res://Assests/tilesets/items/farming-Plants-items.png")
@onready var inventory_slot_scene = preload("res://Scenes/Inventory_Slot.tscn")

const growth_time = {
	0: 10,
	1: 20,
	2: 30,
	3: 40,
}

const GROWTH_STAGES = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.set_tile_map(tile_map)
	set_cells_terrain_connect(Global.SOIL_LAYER, Global.soil_tiles, Global.SOIL_TERRAIN, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle crop growth over time
	for position in Global.crop_tiles.keys():
		var crop = Global.crop_tiles[position]
		#crop["timer"] += delta + 0.01 if randi_range(-1, 1) > 0 else 0 # Adds variation to growth rate
		crop["timer"] += delta * 10
		var current_stage = crop["stage"]
		if current_stage <= GROWTH_STAGES and crop["timer"] >= growth_time[current_stage]:
			advance_growth_stage(crop, position)
	
	if Input.is_action_just_pressed("action"):
		var current_tool = Global.get_current_tool()
		if current_tool == Item.ItemName["HOE"]:
			await animated_sprite_2d.animation_finished
			till_dirt()

	if Input.is_action_just_pressed("alt_action"):
		un_till_dirt()

	if Input.is_action_just_pressed("harvest_crop"):
		harvest_crop()
		
	# Plant seeds
	if Input.is_action_just_pressed("plant_seeds"):
		var hotbar_item = Global.hotbar[Global.hotbar_index]
		if hotbar_item:
			if hotbar_item["item"]["type"] == Item.ItemType["CROP_SEED"]:
				plant_seed(hotbar_item["item"]["item_name"])


func till_dirt():
	var cell_position = get_farmed_tile_position()
	var is_obstructed = check_layers_for_obstruction(cell_position)
	if Global.player_ground_level == 0:
		var tile_data = get_tile_data(Global.GROUND_LAYER, cell_position)
		if tile_data:
			var is_tillable = tile_data.get_custom_data("is_tillable")
			if is_tillable and not is_obstructed:
				Global.soil_tiles.append(cell_position)
				Global.repaint_soil_tiles()
	else:
		var high_elevation_tile_data = get_tile_data(Global.HIGH_ELEVATION_LAYER, cell_position)
		if high_elevation_tile_data:
			var is_tillable = high_elevation_tile_data.get_custom_data("is_tillable")
			if is_tillable and not is_obstructed:
				Global.soil_tiles.append(cell_position)
				Global.repaint_soil_tiles()

func un_till_dirt():
	var cell_position = get_current_cell_position()
	var tile_data = get_tile_data(Global.SOIL_LAYER, cell_position)
	if tile_data:
		var is_tilled = tile_data.get_custom_data("is_tilled")
		if is_tilled:
			Global.soil_tiles.erase(cell_position)
			Global.repaint_soil_tiles()
			
func plant_seed(crop_name):
	var cell_position = get_current_cell_position()
	var soil_tile_data = get_tile_data(Global.SOIL_LAYER, cell_position)
	var crop_tile_data = get_tile_data(Global.CROP_LAYER, cell_position)

	if soil_tile_data and !crop_tile_data:
		var is_tilled = soil_tile_data.get_custom_data("is_tilled")
		if is_tilled:
			Global.crop_tiles[cell_position] = {
				"stage": 0,
				"type": Item.ItemType["CROP_SEED"],
				"timer": 0,
				"name": Item.ItemName[crop_name],
				"atlas_coords": Global.crop_tiles_atlas_coords_map[crop_name][0]
			}
			var current_item = Global.hotbar[Global.hotbar_index];
			if current_item["quantity"] > 1:
				Global.hotbar[Global.hotbar_index]["quantity"] -= 1
				#Global.decrement_item(current_item)
			else:
				Global.hotbar[Global.hotbar_index] = null
				Global.remove_item(current_item)
			crop_sounds.stream.load_from_file(crop_plant_sound)
			crop_sounds.play()
			Global.repaint_crop_tiles()
			Global.inventory_updated.emit()
			
func harvest_crop():
	var cell_position = get_current_cell_position()
	var tile_data = get_tile_data(Global.CROP_LAYER, cell_position)
	if tile_data:
		var crop = Global.crop_tiles[cell_position]
		if crop["stage"] == GROWTH_STAGES:
			# Add crop to inventory
			var item = Item.new(
				Item.ItemType.CROP,
				Item.ItemName[crop["name"]],
				"",
			)
			
			var inventory_item = InventoryItem.new(item, 1)
			
			Global.add_item(inventory_item.to_dict())
			Global.inventory_updated.emit()

			crop_sounds.stream.load_from_file(crop_pickup_sound)
			crop_sounds.play()
			Global.crop_tiles.erase(cell_position)
			Global.repaint_crop_tiles()

func get_farmed_tile_position():
	var cell_position = get_current_cell_position()
	if Global.last_direction == Global.FacingDirection.LEFT:
		return Vector2i(cell_position.x - 1, cell_position.y)
	elif Global.last_direction == Global.FacingDirection.RIGHT:
		return Vector2i(cell_position.x + 1, cell_position.y)
	else:
		return cell_position
		
func check_layers_for_obstruction(position: Vector2i):
	var path_tile_data = get_tile_data(Global.PATH_LAYER, position)
	var flora_tile_data = get_tile_data(Global.FLORA_LAYER, position)
	var decoration_tile_data = get_tile_data(Global.DECORATION_LAYER, position)
	
	if path_tile_data or flora_tile_data or decoration_tile_data:
		return true
	return false
		
func advance_growth_stage(crop, position):
	var current_stage = crop["stage"];
	var crop_name = crop["name"];
	if current_stage < GROWTH_STAGES:
		Global.crop_tiles[position]["stage"] += 1
		Global.crop_tiles[position]["atlas_coords"] = Global.crop_tiles_atlas_coords_map[crop_name][current_stage + 1]
		Global.crop_tiles[position]["timer"] = 0
		Global.repaint_crop_tiles()
		
func get_current_cell_position():
	var player_position = player.global_position
	var cell_position = tile_map.local_to_map(player_position)
	return cell_position;
		
func get_tile_data(layer: int, cell_position: Vector2i):
	var tile_data: TileData = tile_map.get_cell_tile_data(layer, cell_position)
	return tile_data;
