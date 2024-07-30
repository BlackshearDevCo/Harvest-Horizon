extends Button
class_name SaveGame

const SAVE_GAME_PATH = "user://save.data"

func save():
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	
	var saved_data = {}
	
	saved_data["player_global_position"] = Global.player_node.global_position
	saved_data["current_tool"] = Global.current_tool
	saved_data["tool_index"] = Global.tool_index
	saved_data["last_direction"] = Global.last_direction
	saved_data["inventory"] = Global.inventory
	saved_data["hotbar"] = Global.hotbar
	saved_data["soil_tiles"] = Global.soil_tiles
	saved_data["crop_tiles"] = Global.crop_tiles
	
	file.store_var(saved_data)
	file.close()
	
func load():
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	
	var saved_data = file.get_var()
	
	Global.player_node.global_position = saved_data["player_global_position"]
	Global.current_tool = int(saved_data["current_tool"])
	Global.tool_index = saved_data["tool_index"]
	Global.last_direction = int(saved_data["last_direction"])
	Global.inventory = saved_data["inventory"]
	Global.hotbar = saved_data["hotbar"]
	Global.soil_tiles = saved_data["soil_tiles"]
	Global.crop_tiles = saved_data["crop_tiles"]
	Global.repaint_soil_tiles()
	Global.repaint_crop_tiles()
	
	Global.inventory_updated.emit()
	print("Signal emitted")
	print(Global.inventory_updated.get_connections())
	
	file.close()
