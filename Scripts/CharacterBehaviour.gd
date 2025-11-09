extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D
@onready var customization_menu = $CustomizationMenu

var direction = Vector2.ZERO
var speed = 80.0
var screen_size
var passthrough = false

# Window size variables
var default_window_size = Vector2(200, 200)
var menu_window_size = Vector2(200, 200)  # Make it bigger to be safe

func _ready():
	# Set window content scale mode to disabled so it doesn't interfere
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	
	# Set window size FIRST before anything else
	get_window().size = Vector2i(default_window_size)
	get_window().min_size = Vector2i(200, 200)  # Set minimum size
	
	# Wait for window to actually resize
	await get_tree().process_frame
	
	get_viewport().transparent_bg = true
	
	# Position the character at window center
	var window_size = Vector2(get_window().size)
	position = window_size / 2
	
	print("Initial Window size: ", window_size)
	print("Character position: ", position)
	
	# Define the clickable area around the sprite
	var clickable_size = Vector2(100, 100)
	var center = window_size / 2
	
	var polygon = PackedVector2Array([
		center - clickable_size / 2,
		center + Vector2(clickable_size.x / 2, -clickable_size.y / 2),
		center + clickable_size / 2,
		center + Vector2(-clickable_size.x / 2, clickable_size.y / 2)
	])
	
	DisplayServer.window_set_mouse_passthrough(polygon)
	
	sprite.visible = true
	sprite.play("idle")
	
	# Initialize menu
	if customization_menu:
		customization_menu.hide()
		customization_menu.color_changed.connect(_on_color_changed)
		customization_menu.menu_closed.connect(_on_menu_closed)  # Connect the close signal
	
	randomize()
	screen_size = DisplayServer.screen_get_size()
	
	# Position window on screen initially (center of desktop)
	var initial_screen_pos = Vector2(screen_size) / 2
	DisplayServer.window_set_position(Vector2i(initial_screen_pos - window_size / 2))
	
	random_walk()

func _input(event):
	if event is InputEventKey and event.pressed:
		print("Key pressed: ", event.keycode)  # Debug: see what key is pressed
		
		# Toggle menu with F2 (changed from F1)
		if event.keycode == KEY_F2:
			print("F2 detected!")  # Debug
			if customization_menu:
				print("Customization menu exists")  # Debug
				if customization_menu.visible:
					# Hide menu - shrink window
					customization_menu.hide()
					get_window().size = Vector2i(default_window_size)
					print("Menu closed - Window size: ", get_window().size)
				else:
					print("Opening menu...")  # Debug
					# Show menu - expand window FIRST
					get_window().size = Vector2i(menu_window_size)
					print("Window resized to: ", get_window().size)
					
					# Wait for resize to complete
					await get_tree().process_frame
					await get_tree().process_frame  # Wait 2 frames to be sure
					
					# NOW show the menu
					customization_menu.show()
					print("Menu opened - Actual window size: ", get_window().size)
					print("Menu size: ", customization_menu.size)
					print("Panel size: ", customization_menu.get_node("MarginContainer/VBoxContainer/Panel").size if customization_menu.has_node("MarginContainer/VBoxContainer/Panel") else "Panel not found")
			else:
				print("ERROR: Customization menu is null!")  # Debug
				
			get_viewport().set_input_as_handled()
		
		# Toggle passthrough with Ctrl+P
		elif event.keycode == KEY_P and event.ctrl_pressed:
			passthrough = !passthrough
			if passthrough:
				DisplayServer.window_set_mouse_passthrough(PackedVector2Array([]))
			else:
				var window_size = Vector2(get_window().size)
				var clickable_size = Vector2(100, 100)
				var center = window_size / 2
				var polygon = PackedVector2Array([
					center - clickable_size / 2,
					center + Vector2(clickable_size.x / 2, -clickable_size.y / 2),
					center + clickable_size / 2,
					center + Vector2(-clickable_size.x / 2, clickable_size.y / 2)
				])
				DisplayServer.window_set_mouse_passthrough(polygon)

func _physics_process(_delta):
	# Move the window itself around the desktop
	var current_window_pos = DisplayServer.window_get_position()
	var new_window_pos = current_window_pos + Vector2i(direction * speed * _delta)
	
	# Keep window on screen
	var window_size = get_window().size
	new_window_pos.x = clampi(new_window_pos.x, 0, screen_size.x - window_size.x)
	new_window_pos.y = clampi(new_window_pos.y, 0, screen_size.y - window_size.y)
	
	DisplayServer.window_set_position(new_window_pos)
	
	# Flip sprite based on direction
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

func _on_menu_closed():
	get_window().size = Vector2i(default_window_size)
	print("Menu closed via button - Window resized to: ", get_window().size)
