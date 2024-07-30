extends Resource

class_name InventoryItem

@export var item: Item
@export var quantity: int

func _init(item: Item, quantity: int = 1):
	self.item = item
	self.quantity = quantity

func add_quantity(amount: int):
	self.quantity += amount

func remove_quantity(amount: int):
	self.quantity = max(0, self.quantity - amount)

func to_dict() -> Dictionary:
	return {
		"item": item.to_dict(),
		"quantity": quantity,
	}
