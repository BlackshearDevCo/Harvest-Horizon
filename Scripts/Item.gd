extends Resource

class_name Item

const item_texture = preload("res://Assests/tilesets/items/items-spritesheet.png")

const ItemType := {
	CROP = "CROP",
	CROP_SEED = "CROP_SEED",
	TOOL = "TOOL",
	FRUIT = "FRUIT",
	BERRY = "BERRY",
	MUSHROOM = "MUSHROOM",
	FLOWER = "FLOWER",
	RESOURCE = "RESOURCE",
}

const ItemName := {
	# Crops/Crop seeds 
	CAULIFLOWER = "CAULIFLOWER",
	CARROT = "CARROT",
	TOMATO = "TOMATO",
	EGGPLANT = "EGGPLANT",
	TULIP = "TULIP",
	LETTUCE = "LETTUCE",
	TURNIP = "TURNIP",
	WHEAT = "WHEAT",
	PUMPKIN = "PUMPKIN",
	DAHLIA = "DAHLIA",
	BEETROOT = "BEETROOT",
	STARFRUIT = "STARFRUIT",
	CUCUMBER = "CUCUMBER",
	# Tools
	HOE = "HOE",
	AXE = "AXE",
	WATERING_CAN = "WATERING_CAN",
	# Fruits
	APPLE = "APPLE",
	ORANGE = "ORANGE",
	PEAR = "PEAR",
	PEACH = "PEACH",
	# Berries
	RASBERRY = "RASBERRY",
	GRAPE = "GRAPE",
	BLUEBERRY = "BLUEBERRY",
	# Flowers
	SUNFLOWER = "SUNFLOWER",
	AZURE_BELL = "AZURE_BELL",
	LEMON_DROP = "LEMON_DROP",
	# Mushrooms
	BLOSSOM_SHROOM = "BLOSSOM_SHROOM",
	LAVENDER_SHROOM = "LAVENDER_SHROOM",
	# Resources
	STICK = "STICK",
	LOG = "LOG",
	PEBBLE = "PEBBLE",
	ROCK = "ROCK",
}

var ItemRegion = {
	ItemName["CAULIFLOWER"]: {
		ItemType["CROP_SEED"]: Rect2(0, 48, 16, 16),
		ItemType["CROP"]: Rect2(16, 48, 16, 16),
	},
	ItemName["CARROT"]: {
		ItemType["CROP_SEED"]: Rect2(0, 32, 16, 16),
		ItemType["CROP"]: Rect2(16, 32, 16, 16),
	},
	ItemName["TOMATO"]: {
		ItemType["CROP_SEED"]: Rect2(0, 64, 16, 16),
		ItemType["CROP"]: Rect2(16, 64, 16, 16),
	},
	ItemName["EGGPLANT"]: {
		ItemType["CROP_SEED"]: Rect2(0, 80, 16, 16),
		ItemType["CROP"]: Rect2(16, 80, 16, 16),
	},
	ItemName["TULIP"]: {
		ItemType["CROP_SEED"]: Rect2(0, 96, 16, 16),
		ItemType["CROP"]: Rect2(16, 96, 16, 16),
	},
	ItemName["LETTUCE"]: {
		ItemType["CROP_SEED"]: Rect2(0, 112, 16, 16),
		ItemType["CROP"]: Rect2(16, 112, 16, 16),
	},
	ItemName["TURNIP"]: {
		ItemType["CROP_SEED"]: Rect2(0, 160, 16, 16),
		ItemType["CROP"]: Rect2(16, 160, 16, 16),
	},
	ItemName["WHEAT"]: {
		ItemType["CROP_SEED"]: Rect2(0, 128, 16, 16),
		ItemType["CROP"]: Rect2(16, 128, 16, 16),
	},
	ItemName["PUMPKIN"]: {
		ItemType["CROP_SEED"]: Rect2(0, 144, 16, 16),
		ItemType["CROP"]: Rect2(16, 144, 16, 16),
	},
	ItemName["DAHLIA"]: {
		ItemType["CROP_SEED"]: Rect2(0, 176, 16, 16),
		ItemType["CROP"]: Rect2(16, 176, 16, 16),
	},
	ItemName["BEETROOT"]: {
		ItemType["CROP_SEED"]: Rect2(0, 192, 16, 16),
		ItemType["CROP"]: Rect2(16, 192, 16, 16),
	},
	ItemName["STARFRUIT"]: {
		ItemType["CROP_SEED"]: Rect2(0, 208, 16, 16),
		ItemType["CROP"]: Rect2(16, 208, 16, 16),
	},
	ItemName["CUCUMBER"]: {
		ItemType["CROP_SEED"]: Rect2(0, 224, 16, 16),
		ItemType["CROP"]: Rect2(16, 224, 16, 16),
	},
	ItemName["HOE"]: {
		ItemType["TOOL"]: Rect2(48, 0, 16, 16)
	},
	ItemName["AXE"]: {
		ItemType["TOOL"]: Rect2(32, 0, 16, 16)
	},
	ItemName["WATERING_CAN"]: {
		ItemType["TOOL"]: Rect2(32, 16, 16, 16)
	},
}

var type: String
var item_name: String
var description: String
var texture: Texture
var texture_reigon: Rect2
var attributes: Dictionary = {}  # Store specific item attributes here

func _init(
	type: String,
	item_name: String,
	description: String,
	attributes: Dictionary = {},
):
	self.type = type
	self.item_name = item_name
	self.description = description
	self.texture = item_texture
	self.texture_reigon = ItemRegion[item_name][type]
	self.attributes = attributes
	
func to_dict() -> Dictionary:
	return {
		"type": type,
		"item_name": item_name,
		"description": description,
		"texture": texture.resource_path,
		"texture_reigon": ItemRegion[item_name][type],
		"attributes": attributes,
	}
