extends Node2D

@onready var customization_menu = $CustomizationMenu
@onready var character = $CharacterBody2D

var clickable_only_character = false

func _ready() -> void:
	DisplayServer.window_set_mouse_passthrough(PackedVector2Array([]))
	set_process(false)
	if customization_menu and character:
		customization_menu.color_changed.connect(change_character_color)
	
func change_character_color(color: Color):
	if character:
		var sprite = character.get_node("AnimatedSprite2D")
		if sprite:
			sprite.modulate = color
	
func _toggle_passthrough():
	if customization_menu.visible and clickable_only_character:
		print("Cannot toggle to Full Passthrough while the menu is open.")
		return
	
	clickable_only_character = !clickable_only_character
	
	if clickable_only_character:
		set_process(true)
		print("Passthrough OFF: Only Character Clickable")
	else:
		set_process(false)
		DisplayServer.window_set_mouse_passthrough(PackedVector2Array([]))
		print("Passthrough ON: Entire Window Passthrough")
	
func _process(_delta):
	if clickable_only_character and character:
		if customization_menu.visible:
			var menu_rect = customization_menu.get_global_transform_with_canvas().xform(customization_menu.get_rect())
			var menu_polygon = PackedVector2Array([
				menu_rect.position,
				menu_rect.position + Vector2(menu_rect.size.x, 0),
				menu_rect.position + menu_rect.size,
				menu_rect.position + Vector2(0, menu_rect.size.y)
			])
		
			DisplayServer.window_set_mouse_passthrough(menu_polygon)
		
		else:
			var character_polygon = character.get_bounding_polygon()
			DisplayServer.window_set_mouse_passthrough(character_polygon)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("passthrough"):
		_toggle_passthrough()
		return
	if clickable_only_character:
		if event.is_action_pressed("toggle_menu"):
			customization_menu.show()
		if event.is_action_pressed("ui_cancel") and customization_menu.visible:
			customization_menu.hide()
