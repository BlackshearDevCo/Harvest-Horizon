extends Control

@onready var grid_container = $GridContainer

const slot_region = Rect2(59, 59, 26, 26)
const selected_slot_region = Rect2(107, 59, 26, 26)

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.inventory_updated.connect(_on_inventory_updated)
	Global.inventory_index_updated.connect(_on_inventory_index_updated)
	_on_inventory_updated()
	_on_inventory_index_updated()
	
func _on_inventory_index_updated():
	var slots = grid_container.get_children()
	for index in range(slots.size()):
		var slot = grid_container.get_child(index).get_child(1)
		if (index == Global.inventory_index):
			slot.region_rect = selected_slot_region
		else:
			slot.region_rect = slot_region

func _on_inventory_updated():
	clear_grid_container()
	for item in Global.inventory.values():
		var slot = Global.inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()

func clear_grid_container():
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()
