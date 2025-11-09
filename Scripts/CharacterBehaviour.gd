extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var customization_menu = $MarginContainer/VBoxContainer/Panel

var direction = Vector2.ZERO
var speed = 80.0
var screen_size: Vector2
var passthrough = false

# Window size variables
var default_window_size = Vector2(200, 200)
var menu_window_size = Vector2(700, 700)

func _ready():
	# Disable content scale mode for proper resizing
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	
	# Set default window size and minimum size
	get_window().size = Vector2i(default_window_size)
	get_window().min_size = Vector2i(200, 200)
	await get_tree().process_frame
	
	get_viewport().transparent_bg = true
	
	# Center character in window
	position = Vector2(get_window().size) / 2
	sprite.visible = true
	sprite.play("idle")
	
	# Get screen size
	screen_size = DisplayServer.screen_get_size()
	
	# Calculate window center position safely
	var window_size_vec2 = Vector2(get_window().size)
	var center_pos_vec2 = screen_size / 2 - window_size_vec2 / 2
	var center_pos = center_pos_vec2.to_vector2i()
	DisplayServer.window_set_position(center_pos)
	
	# Instantiate customization menu
	var menu_scene = preload("res://Scenes/customization_menu.tscn")  # Update path!
	customization_menu = menu_scene.instantiate()
	add_child(customization_menu)
	customization_menu.hide()
	customization_menu.color_changed.connect(_on_color_changed)
	
	# Set initial clickable area
	_update_mouse_passthrough()
	
	randomize()
	random_walk()

func _update_mouse_passthrough():
	var window_size_vec2 = Vector2(get_window().size)
	var clickable_size = Vector2(100, 100)
	var center = window_size_vec2 / 2
	var polygon = PackedVector2Array([
		center - clickable_size / 2,
		center + Vector2(clickable_size.x / 2, -clickable_size.y / 2),
		center + clickable_size / 2,
		center + Vector2(-clickable_size.x / 2, clickable_size.y / 2)
	])
	if passthrough:
		DisplayServer.window_set_mouse_passthrough(PackedVector2Array([]))
	else:
		DisplayServer.window_set_mouse_passthrough(polygon)

func _input(event):
	if event is InputEventKey and event.pressed:
		# Toggle menu with F2
		if event.keycode == KEY_F2 and customization_menu:
			if customization_menu.visible:
				customization_menu.hide()
				get_window().size = Vector2i(default_window_size)
			else:
				get_window().size = Vector2i(menu_window_size)
				await get_tree().process_frame
				await get_tree().process_frame  # Wait 2 frames for resize
				customization_menu.show()
			_update_mouse_passthrough()
			get_viewport().set_input_as_handled()
		
		# Toggle passthrough with Ctrl+P
		elif event.keycode == KEY_P and event.ctrl_pressed:
			passthrough = !passthrough
			_update_mouse_passthrough()

func _physics_process(_delta):
	# Move the window around the desktop
	var current_window_pos = DisplayServer.window_get_position()
	var new_window_pos_vec2 = Vector2(current_window_pos) + direction * speed * _delta
	var new_window_pos = new_window_pos_vec2.to_vector2i()
	
	# Keep window on screen
	var window_size_vec2 = Vector2(get_window().size)
	new_window_pos.x = clamp(new_window_pos.x, 0, screen_size.x - window_size_vec2.x)
	new_window_pos.y = clamp(new_window_pos.y, 0, screen_size.y - window_size_vec2.y)
	
	DisplayServer.window_set_position(new_window_pos)
	
	# Flip sprite
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false

func random_walk():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if direction != Vector2.ZERO:
		sprite.play("walkSide")
	else:
		sprite.play("idle")
	await get_tree().create_timer(randf_range(2, 4)).timeout
	random_walk()

func move_to_position_target(target_pos: Vector2):
	direction = (target_pos - position).normalized()

func stop():
	direction = Vector2.ZERO
	sprite.play("idle")

# Customization callbacks
func _on_color_changed(color: Color):
	sprite.modulate = color
