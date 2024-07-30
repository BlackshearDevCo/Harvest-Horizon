extends Control

@onready var frame = $Frame
@onready var item_icon = $Frame/Control/ItemIcon
@onready var item_quantity = $Frame/Control/ItemQuantity
@onready var usage_panel = $UsagePanel
@onready var assign_button = $UsagePanel/NinePatchRect/AssignButton
@onready var usage_panel_label = $UsagePanel/NinePatchRect/Label

var item = null
var slot_index = -1
var is_assigned = false

const LABEL_BASE_TEXT = " to hotbar"

func _on_item_button_pressed():
	if item != null and item["item"]["type"] != Item.ItemType["TOOL"]:
		usage_panel.visible = !usage_panel.visible
	
func update_assignment_status():
	is_assigned = Global.is_item_assigned_to_hotbar(item)
	if is_assigned:
		usage_panel_label.text = "Unassign" + LABEL_BASE_TEXT
	else:
		usage_panel_label.text = "Assign" + LABEL_BASE_TEXT

func set_slot_index(new_index):
	slot_index = new_index

func set_empty():
	item_icon.texture = null
	item_quantity.text = ""
	
func set_item(new_item):
	item = new_item
	item_icon.texture = load(new_item["item"]["texture"])
	item_icon.region_rect = new_item["item"]["texture_reigon"]
	item_quantity.text = str(new_item["quantity"])
	if new_item["quantity"] == 0:
		item_quantity.visible = false
		
	update_assignment_status()

func _on_mouse_entered():
	var index = Global.get_inventory_index_from_node(self)
	Global.update_inventory_index(index)

func _on_assign_button_pressed():
	handle_assign_button()

func handle_assign_button():
	if item != null:
		if is_assigned:
			Global.unassign_hotbar_item(item)
			is_assigned = false
		else:
			Global.add_item(item, true)
			is_assigned = true
		
		update_assignment_status()
