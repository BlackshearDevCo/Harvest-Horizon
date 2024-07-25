#@tool
extends Node2D

var scene_path: String = "res://Scenes/Inventory_Item.tscn"


@export var item_type: Global.ItemTypes
@export var item_name: Global.ItemNames
@export var item_texture: Texture
@export var item_texture_reigon: Rect2

@onready var icon_sprite = $Sprite2D

var player_in_range = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set texture reigon in tileset
	icon_sprite.region_rect = Global.item_reigons[item_name][item_type]
	item_texture_reigon  = Global.item_reigons[item_name][item_type]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		pickup_item()


func pickup_item():
	var item = {
		"quantity": 1,
		"type": item_type,
		"name": item_name,
		"texture": item_texture,
		"scene_path": scene_path,
		"texture_reigon": item_texture_reigon,
	}
	
	if Global.player_node:
		Global.add_item(item)
		self.queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		body.interact_ui.visible = true
		self.scale = Vector2(1.1, 1.1)


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		body.interact_ui.visible = false
		self.scale = Vector2(1, 1)
