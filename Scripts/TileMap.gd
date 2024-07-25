extends TileMap

@onready var tile_map = %TileMap
@onready var player = %Player
@onready var animated_sprite_2d = %Player/AnimatedSprite2D

const farming_items_texture = preload("res://Assests/tilesets/items/farming-Plants-items.png")
@onready var inventory_slot_scene = preload("res://Scenes/Inventory_Slot.tscn")

const growth_time = {
	0: 10,
	1: 20,
	2: 30,
	3: 30,
	4: 40,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.set_tile_map(tile_map)
	set_cells_terrain_connect(Global.SOIL_LAYER, Global.soil_tiles, Global.SOIL_TERRAIN, 0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for position in Global.crop_tiles.keys():
		var crop = Global.crop_tiles[position]
		#crops[position]["timer"] += delta + randi_range(-1, 1) # Adds variation to growth rate
		crop["timer"] += delta * 10	
		var current_stage = crop["stage"]
		if current_stage <= crop["growth_stages"] and crop["timer"] >= growth_time[current_stage]:
			advance_growth_stage(crop, position)
	
	if Input.is_action_just_pressed("action") and Global.current_tool == Global.Tools.HOE:
		await animated_sprite_2d.animation_finished
		till_dirt()


	if Input.is_action_just_pressed("alt_action"):
		un_till_dirt()

	if Input.is_action_just_pressed("harvest_crop"):
		harvest_crop()
		
	# Plant seeds
	if Input.is_action_just_pressed("plant_seeds"):
		var inventory_item = Global.inventory[Global.inventory_index]
		if inventory_item:
			if inventory_item["type"] == Global.ItemTypes.SEED:
				plant_seed(inventory_item["name"])


func till_dirt():
	var cell_position = get_farmed_tile_position()
	var tile_data: TileData = tile_map.get_cell_tile_data(Global.GROUND_LAYER, cell_position)
	if tile_data:
		var is_tillable = tile_data.get_custom_data("is_tillable")
		if is_tillable:
			Global.soil_tiles.append(cell_position)
			Global.repaint_soil_tiles()

func un_till_dirt():
	var player_position = player.global_position
	var cell_position = tile_map.local_to_map(player_position)
	var tile_data: TileData = tile_map.get_cell_tile_data(Global.SOIL_LAYER, cell_position)
	if tile_data:
		var is_tilled = tile_data.get_custom_data("is_tilled")
		if is_tilled:
			Global.soil_tiles.erase(cell_position)
			Global.repaint_soil_tiles()
			
func plant_seed(crop_name: Global.ItemNames):
	var crop_type = Global.item_name_map[crop_name]
	var player_position = player.global_position
	var cell_position = tile_map.local_to_map(player_position)
	var soil_tile_data: TileData = tile_map.get_cell_tile_data(Global.SOIL_LAYER, cell_position)
	var crop_tile_data: TileData = tile_map.get_cell_tile_data(Global.CROP_LAYER, cell_position)
	if soil_tile_data and !crop_tile_data:
		var is_tilled = soil_tile_data.get_custom_data("is_tilled")
		if is_tilled:
			Global.crop_tiles[cell_position] = {
				"stage": 0,
				"atlas_coords": Global.crop_tiles_atlas_coords_map[crop_type][0],
				"type": crop_type,
				"timer": 0,
				"growth_stages": 3,
				"name_id": crop_name,
			}
			var current_item = Global.inventory[Global.inventory_index];
			if current_item["quantity"] > 1:
				Global.inventory[Global.inventory_index]["quantity"] -= 1
			else:
				Global.inventory[Global.inventory_index] = null
			Global.repaint_crop_tiles()
			Global.inventory_updated.emit()
			
func harvest_crop():
	var player_position = player.global_position
	var cell_position = tile_map.local_to_map(player_position)
	var tile_data: TileData = tile_map.get_cell_tile_data(Global.CROP_LAYER, cell_position)
	if tile_data:
		var crop = Global.crop_tiles[cell_position]
		if crop["stage"] == crop["growth_stages"]:
			# Add crop to inventory
			Global.add_item({
				"quantity": 1,
				"type": Global.ItemTypes.CROP,
				"name": crop["name_id"],
				"texture": farming_items_texture,
				"scene_path": inventory_slot_scene,
				"texture_reigon": Global.item_reigons[crop["name_id"]][Global.ItemTypes.CROP],
			})
			Global.crop_tiles.erase(cell_position)
			Global.repaint_crop_tiles()

func get_farmed_tile_position():
	var player_position = player.global_position
	var cell_position = tile_map.local_to_map(player_position)
	if Global.last_direction == Global.FacingDirection.LEFT:
		return Vector2i(cell_position.x - 1, cell_position.y)
	elif Global.last_direction == Global.FacingDirection.RIGHT:
		return Vector2i(cell_position.x + 1, cell_position.y)
	else:
		return cell_position
		
		
func advance_growth_stage(crop, position):
	var current_stage = crop["stage"];
	if current_stage < crop["growth_stages"]:
		Global.crop_tiles[position]["stage"] += 1
		Global.crop_tiles[position]["atlas_coords"] = Global.crop_tiles_atlas_coords_map[crop["type"]][current_stage + 1]
		Global.crop_tiles[position]["timer"] = 0
		Global.repaint_crop_tiles()
