extends Control

@onready var frame = $Frame
@onready var item_icon = $Frame/Control/ItemIcon
@onready var item_quantity = $Frame/Control/ItemQuantity
@onready var item_name = $"DetailsPanel/Item Name"
@onready var item_type = $"DetailsPanel/Item Type"
@onready var usage_panel = $UsagePanel
@onready var details_panel = $DetailsPanel

var item = null


func _on_item_button_pressed():
	if item != null:
		usage_panel.visible = !usage_panel.visible

func _on_item_button_mouse_entered():
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true

func _on_item_button_mouse_exited():
	details_panel.visible = false

func set_empty():
	item_icon.texture = null
	item_quantity.text = ""
	
func set_item(new_item):
	item = new_item
	item_icon.texture = new_item["texture"]
	item_icon.region_rect = new_item["texture_reigon"]
	item_quantity.text = str(new_item["quantity"])
	item_name.text = Global.item_name_map[new_item["name"]]
	item_type.text = Global.item_type_map[new_item["type"]]
