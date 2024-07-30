extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var water_sprite = $WaterSprite
@onready var inventory_ui = $InventoryUI
@onready var hotbar_ui = $HotbarUI
@onready var shop_ui = $ShopUI
@onready var footstep_player = $FootstepPlayer
@onready var footstep_timer: Timer = $FootstepTimer

@export var speed := 100
@export var acceleration := 1000.0

var direction: Vector2 = Vector2.ZERO
var playing_action_animation = false
var initial_water_position: Vector2i
var can_play_footstep = true  # To control when to play the sound

func _ready():
	initial_water_position = water_sprite.position
	Global.set_player_node(self)
	Global.inventory_open_updated.connect(_on_inventory_open_updated)
	footstep_timer.connect("timeout", _on_footstep_timer_timeout)
	
func _on_footstep_timer_timeout():
	footstep_player.play()

func _on_inventory_open_updated():
	inventory_ui.visible = !inventory_ui.visible
	get_tree().paused = !get_tree().paused
	
func _process(delta):
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
	
	if Input.is_action_just_pressed("change_hotbar_index_left"):
		var new_index = Global.hotbar_index - 1
		var inventory_size = Global.hotbar.size()
		if new_index < 0:
			Global.update_hotbar_index(inventory_size + new_index)
		else:
			Global.update_hotbar_index(new_index)

	if Input.is_action_just_pressed("change_hotbar_index_right"):
		var new_index = Global.hotbar_index + 1
		if new_index > Global.hotbar.size() - 1:
			Global.update_hotbar_index(0)
		else:
			Global.update_hotbar_index(new_index)
	
	if Global.inventory_open:
		return;
		
	if Input.is_action_just_pressed("change_tool_up"):
		var tools = Global.tools
		var new_index = Global.tool_index + 1
		if new_index > tools.size() - 1:
			Global.update_tool_index(0)
		else:
			Global.update_tool_index(new_index)

	if Input.is_action_just_pressed("change_tool_down"):
		var tools = Global.tools
		var new_index = Global.tool_index - 1
		if new_index < 0:
			Global.update_tool_index(tools.size() - 1)
		else:
			Global.update_tool_index(new_index)

	# Action animations
	if Input.is_action_just_pressed("action"):
		playing_action_animation = true
		var current_tool = Global.get_current_tool()
		if current_tool == Item.ItemName["AXE"]:
			if Global.last_direction == Global.FacingDirection.UP:
				animated_sprite_2d.play("swing_axe_up")
			if Global.last_direction == Global.FacingDirection.DOWN:
				animated_sprite_2d.play("swing_axe_down")
			if Global.last_direction == Global.FacingDirection.LEFT:
				animated_sprite_2d.play("swing_axe_left")
			if Global.last_direction == Global.FacingDirection.RIGHT:
				animated_sprite_2d.play("swing_axe_right")
		if current_tool == Item.ItemName["HOE"]:
			if Global.last_direction == Global.FacingDirection.UP:
				animated_sprite_2d.play("swing_hoe_up")
			if Global.last_direction == Global.FacingDirection.DOWN:
				animated_sprite_2d.play("swing_hoe_down")
			if Global.last_direction == Global.FacingDirection.LEFT:
				animated_sprite_2d.play("swing_hoe_left")
			if Global.last_direction == Global.FacingDirection.RIGHT:
				animated_sprite_2d.play("swing_hoe_right")
		if current_tool == Item.ItemName["WATERING_CAN"]:
			if Global.last_direction == Global.FacingDirection.UP:
				water_sprite.position = Vector2i(initial_water_position.x + 10, initial_water_position.y - 12)
				animated_sprite_2d.play("pour_water_up")
				water_sprite.play("water_down")
			if Global.last_direction == Global.FacingDirection.DOWN:
				water_sprite.position = Vector2i(initial_water_position.x, initial_water_position.y - 2)
				animated_sprite_2d.play("pour_water_down")
				water_sprite.play("water_down")
			if Global.last_direction == Global.FacingDirection.LEFT:
				animated_sprite_2d.play("pour_water_left")
				water_sprite.position = Vector2i(initial_water_position.x - 16, initial_water_position.y - 5)
				water_sprite.play("water_left")
			if Global.last_direction == Global.FacingDirection.RIGHT:
				water_sprite.position = Vector2i(initial_water_position.x + 16, initial_water_position.y - 5)
				animated_sprite_2d.play("pour_water_right")
				water_sprite.play("water_right")
				
	if Global.in_shop_range:
		if Input.is_action_just_pressed("interact"):
			shop_ui.visible = !shop_ui.visible
			Global.shop_open = shop_ui.visible

func _physics_process(delta):
	z_index = int(global_position.y)
	# Character Movement
	var direction = Input.get_vector("left", "right", "up", "down")
	direction = direction.normalized()
	var target_velocity = direction * speed
	var threshold = 0.1
	
	# Set player ground level
	var cell_position = Global.tile_map_node.local_to_map(self.global_position)
	var tile_data: TileData = Global.tile_map_node.get_cell_tile_data(Global.HIGH_ELEVATION_LAYER, cell_position)
	if tile_data:
		Global.player_ground_level = 1
	elif Global.player_ground_level != 0:
		Global.player_ground_level = 0
		
	if Global.inventory_open or Global.shop_open:
		return;
		
	# Walking/Idle Animations
	if not playing_action_animation:
		water_sprite.stop()
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

	if not playing_action_animation:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		move_and_slide()
		
	# Waliking Audio
	if velocity.length() > 0:
		if footstep_timer.is_stopped():
			footstep_player.play()
			footstep_timer.start()
	else:
		footstep_timer.stop()


func _input(event):
	if event.is_action_pressed("inventory") and Global.shop_open == false:
		Global.toggle_inventory_open()
		
	for i in range(Global.hotbar.size()):
		if event.is_action_pressed("hotbar_shortcut_" + str(i + 1)):
			Global.update_hotbar_index(i)

func _on_animated_sprite_2d_animation_finished():
	playing_action_animation = false
	
