extends VBoxContainer

@onready var shop_ui_item = $"."
@onready var item_icon = $Item/ItemIcon
@onready var quantity_label = $Item/Quantity
@onready var price_label = $PriceContainer/Price
@onready var item_button = $Item/ItemButton

var item: Item
var quantity: int
var price: int

func _ready():
	Global.wallet_updated.connect(_on_wallet_updated)
	Global.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()
	#_on_wallet_updated()

func _on_inventory_updated():
	pass
	#if item and item.attributes["action"] == "sell":
		#for i in range(Global.inventory.size()):
			#var inventory_item = Global.inventory[i]
			#if inventory_item != null and inventory_item["item"]["type"] == item["type"] and inventory_item["item"]["item_name"] == item["item_name"]:
				#item_button.disabled = false
				#shop_ui_item.modulate = Color(1, 1, 1, 1)
			#else:
				#item_button.disabled = true
				#shop_ui_item.modulate = Color(1, 1, 1, 0.5)

func _on_wallet_updated():
	if item.attributes["action"] == "buy":
		if not has_enough_money():
			item_button.disabled = true
			shop_ui_item.modulate = Color(1, 1, 1, 0.5)
		else:
			item_button.disabled = false
			shop_ui_item.modulate = Color(1, 1, 1, 1)

func set_item(new_item):
	item = new_item
	quantity = item.attributes["quantity"]
	price = item.attributes["price"]
	item_icon.texture = item.texture
	item_icon.region_rect = item.texture_reigon
	quantity_label.text = str(item.attributes.quantity)
	price_label.text = str(item.attributes.price)
	item_button.tooltip_text = item.attributes["action"].capitalize() + " " + str(quantity) + " " + item["item_name"].capitalize() + " " + item_type_to_readable_text()
	_on_inventory_updated()
	_on_wallet_updated()

func has_enough_money():
	return price <= Global.wallet

func _on_item_button_pressed():
	if item.attributes["action"] == "sell":
		for i in range(Global.inventory.size()):
			var inventory_item = Global.inventory[i]
			if inventory_item != null and inventory_item["item"]["type"] == item["type"] and inventory_item["item"]["item_name"] == item["item_name"]:
				if inventory_item["quantity"] > quantity:
					Global.inventory[i]["quantity"] -= quantity
					Global.set_wallet(Global.wallet + (quantity * price))
					Global.inventory_updated.emit()
				else:
					Global.remove_item(inventory_item)
					Global.set_wallet(Global.wallet + (quantity * price))
	else:
		var inventory_item = InventoryItem.new(item, quantity)
		if has_enough_money():
			Global.add_item(inventory_item.to_dict())
			Global.set_wallet(Global.wallet - price)

func item_type_to_readable_text():
	var readable_text := {
		Item.ItemType.CROP: "crop",
		Item.ItemType.CROP_SEED: "seed",
		Item.ItemType.TOOL: "",
		Item.ItemType.FRUIT: "",
		Item.ItemType.BERRY: "",
		Item.ItemType.MUSHROOM: "",
		Item.ItemType.FLOWER: "",
		Item.ItemType.RESOURCE: "",
	}

	if readable_text.has(item["type"]):
		return readable_text[item["type"]]
	else:
		return "Unknown"
		
