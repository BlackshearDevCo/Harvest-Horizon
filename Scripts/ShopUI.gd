extends Control

@onready var wallet = $ShopContainer/Control/Title/HBoxContainer/Wallet
@onready var buy_grid = $ShopContainer/ShopItemsContainer/Buy/BuyContainer/BuyGrid
@onready var sell_grid = $ShopContainer/ShopItemsContainer/Sell/SellContainer/SellGrid

@onready var shop_ui_item_scene = preload("res://Scenes/ShopUIItem.tscn")


var purchase_items = [
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["CARROT"], "", {"price": 5, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["WHEAT"], "", {"price": 5, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["LETTUCE"], "", {"price": 5, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["CAULIFLOWER"], "", {"price": 15, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["CUCUMBER"], "", {"price": 15, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["TOMATO"], "", {"price": 15, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["EGGPLANT"], "", {"price": 25, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["TURNIP"], "", {"price": 25, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["BEETROOT"], "", {"price": 25, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["PUMPKIN"], "", {"price": 50, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["TULIP"], "", {"price": 50, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["STARFRUIT"], "", {"price": 100, "quantity": 5, "action": "buy", "tooltip": ""}),
	Item.new(Item.ItemType["CROP_SEED"], Item.ItemName["DAHLIA"], "", {"price": 100, "quantity": 5, "action": "buy", "tooltip": ""}),
]

var sell_items = [
	Item.new(Item.ItemType["CROP"], Item.ItemName["CARROT"], "", {"price": 1, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["WHEAT"], "", {"price": 1, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["LETTUCE"], "", {"price": 1, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["CAULIFLOWER"], "", {"price": 3, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["CUCUMBER"], "", {"price": 3, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["TOMATO"], "", {"price": 3, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["EGGPLANT"], "", {"price": 5, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["TURNIP"], "", {"price": 5, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["BEETROOT"], "", {"price": 5, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["PUMPKIN"], "", {"price": 10, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["TULIP"], "", {"price": 10, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["STARFRUIT"], "", {"price": 25, "quantity": 1, "action": "sell", "tooltip": ""}),
	Item.new(Item.ItemType["CROP"], Item.ItemName["DAHLIA"], "", {"price": 25, "quantity": 1, "action": "sell", "tooltip": ""}),
]

func _ready():
	Global.wallet_updated.connect(_on_wallet_updated)
	_on_wallet_updated()
	populate_shop()
	
func populate_shop():
	# Clear existing items
	clear_buy_children()
	clear_sell_children()

	# Iterate over the items list and create ShopUIItem nodes
	for item in purchase_items:
		var shop_item = shop_ui_item_scene.instantiate()
		# Add the shop item to the grid
		buy_grid.add_child(shop_item)
		# Set properties for the shop item
		shop_item.set_item(item)

	# Iterate over the items list and create ShopUIItem nodes
	for item in sell_items:
		var shop_item = shop_ui_item_scene.instantiate()
		# Add the shop item to the grid
		sell_grid.add_child(shop_item)
		# Set properties for the shop item
		shop_item.set_item(item)

func _on_wallet_updated():
	wallet.text = str(Global.wallet)

func has_enough_money(price):
	return price <= Global.wallet

func clear_buy_children():
	for child in buy_grid.get_children():
		child.queue_free()

func clear_sell_children():
	for child in sell_grid.get_children():
		child.queue_free()
