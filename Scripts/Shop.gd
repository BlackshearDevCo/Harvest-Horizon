extends Node2D

@onready var sign_ui = $SignUI

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		sign_ui.visible = true
		Global.in_shop_range = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		sign_ui.visible = false
		Global.in_shop_range = false
