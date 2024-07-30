extends Control

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var water_sprite = $WaterSprite
@onready var hotbar_container = $HotbarWrapper/Hotbar
@onready var tool_slot = $HotbarWrapper/ToolSlotContainer

@onready var slot_scene = preload("res://Scenes/Inventory_Slot.tscn")
const tool_items_texture = preload("res://Assests/tilesets/items/tools-n-meterial-items.png")

const slot_region = Rect2(59, 59, 26, 26)
const selected_slot_region = Rect2(107, 59, 26, 26)

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()
	Global.hotbar_index_updated.connect(_on_hotbar_index_updated)
	_on_hotbar_index_updated()
	Global.tool_index_updated.connect(_on_tool_index_updated)
	_on_tool_index_updated()
	
func _on_inventory_updated():
	print("CONNECTED")
	clear_hotbar_container()
	for i in range(Global.hotbar.size()):
		var slot = slot_scene.instantiate()
		slot.set_slot_index(i)
		hotbar_container.add_child(slot)
		if Global.hotbar[i] != null:
			slot.set_item(Global.hotbar[i])
		else:
			slot.set_empty()
			
		slot.update_assignment_status()
			
func _on_hotbar_index_updated():
	var hotbar_slots = hotbar_container.get_children()
	for index in range(hotbar_slots.size()):
		var slot = hotbar_container.get_child(index)
		if (index == Global.hotbar_index):
			slot.get_child(0).region_rect = selected_slot_region
		else:
			slot.get_child(0).region_rect = slot_region
			
func _on_tool_index_updated():
	var slot = slot_scene.instantiate()
	var item = Item.new(
		Item.ItemType.TOOL,
		Global.get_current_tool(),
		"",
	)
	var inventory_item = InventoryItem.new(item, 0)

	var exisitng_slot = tool_slot.get_child(0)
	if exisitng_slot: exisitng_slot.queue_free()
	tool_slot.add_child(slot)
	slot.set_item(inventory_item.to_dict())

func clear_hotbar_container():
	while hotbar_container.get_child_count() > 0:
		var child = hotbar_container.get_child(0)
		hotbar_container.remove_child(child)
		child.queue_free()
