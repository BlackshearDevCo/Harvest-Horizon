extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var interact_ui = $InteractUI
@onready var inventory_ui = $InventoryUI

@export var speed := 100
@export var acceleration := 1000.0


var direction: Vector2 = Vector2.ZERO
var playing_action_animation = false


func _ready():
	Global.set_player_node(self)
	Global.inventory_open_updated.connect(_on_inventory_open_updated)


func _on_inventory_open_updated():
	inventory_ui.visible = !inventory_ui.visible
	get_tree().paused = !get_tree().paused

func _physics_process(delta):
	z_index = int(global_position.y)
	# Character Movement
	var direction = Input.get_vector("left", "right", "up", "down")
	direction = direction.normalized()
	var target_velocity = direction * speed
	var threshold = 0.1
	
	if Global.inventory_open:
		if Input.is_action_just_pressed("change_inventory_index_right"):
			var new_index = Global.inventory_index + 1
			if new_index > Global.inventory.size() - 1:
				Global.update_inventory_index(0)
			else:
				Global.update_inventory_index(new_index)
				
		if Input.is_action_just_pressed("change_inventory_index_left"):
			var new_index = Global.inventory_index - 1
			if new_index < 0:
				Global.update_inventory_index(Global.inventory.size() -1)
			else:
				Global.update_inventory_index(new_index)
				
		if Input.is_action_just_pressed("change_inventory_index_down"):
			var new_index = Global.inventory_index + 9
			var inventory_size = Global.inventory.size()
			if new_index > inventory_size:
				Global.update_inventory_index(new_index - inventory_size)
			else:
				Global.update_inventory_index(new_index)
				
		if Input.is_action_just_pressed("change_inventory_index_up"):
			var new_index = Global.inventory_index - 9
			var inventory_size = Global.inventory.size()
			if new_index < 0:
				Global.update_inventory_index(inventory_size + new_index)
			else:
				Global.update_inventory_index(new_index)
				
		if Input.is_action_just_pressed("back"):
			Global.toggle_inventory_open()
	
	if Global.inventory_open:
		return;
	
	# Walking/Idle Animations
	if not playing_action_animation:
		# Walking/Idle
		if direction.x == 0 and direction.y == 0:
			if Global.last_direction == Global.FacingDirection.UP:
				animated_sprite_2d.play("idle_up")
			if Global.last_direction == Global.FacingDirection.DOWN:
				animated_sprite_2d.play("idle")
			if Global.last_direction == Global.FacingDirection.LEFT:
				animated_sprite_2d.play("idle_left")
			if Global.last_direction == Global.FacingDirection.RIGHT:
				animated_sprite_2d.play("idle_right")
		elif abs(direction.x) < abs(direction.y) + threshold:
			# Moving vertically
			if direction.y > 0:
				animated_sprite_2d.play("walk_down")
				Global.update_direction(Global.FacingDirection.DOWN)
			else:
				animated_sprite_2d.play("walk_up")
				Global.update_direction(Global.FacingDirection.UP)
		else:
			# Moving horizontally
			if direction.x > 0:
				animated_sprite_2d.play("walk_right")
				Global.update_direction(Global.FacingDirection.RIGHT)
			else:
				animated_sprite_2d.play("walk_left")
				Global.update_direction(Global.FacingDirection.LEFT)
				
	# Action animations
	if Input.is_action_just_pressed("action"):
		playing_action_animation = true
		if Global.current_tool == Global.Tools.AXE:
			if Global.last_direction == Global.FacingDirection.UP:
				animated_sprite_2d.play("swing_axe_up")
			if Global.last_direction == Global.FacingDirection.DOWN:
				animated_sprite_2d.play("swing_axe_down")
			if Global.last_direction == Global.FacingDirection.LEFT:
				animated_sprite_2d.play("swing_axe_left")
			if Global.last_direction == Global.FacingDirection.RIGHT:
				animated_sprite_2d.play("swing_axe_right")
		if Global.current_tool == Global.Tools.HOE:
			if Global.last_direction == Global.FacingDirection.UP:
				animated_sprite_2d.play("swing_hoe_up")
			if Global.last_direction == Global.FacingDirection.DOWN:
				animated_sprite_2d.play("swing_hoe_down")
			if Global.last_direction == Global.FacingDirection.LEFT:
				animated_sprite_2d.play("swing_hoe_left")
			if Global.last_direction == Global.FacingDirection.RIGHT:
				animated_sprite_2d.play("swing_hoe_right")
			

	if not playing_action_animation:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		move_and_slide()


func _input(event):
	if event.is_action_pressed("inventory"):
		Global.toggle_inventory_open()

func _on_animated_sprite_2d_animation_finished():
	playing_action_animation = false
