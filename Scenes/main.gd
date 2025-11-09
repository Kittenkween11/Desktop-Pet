extends Node2D

@onready var customization_menu = $CustomizationMenu

var passthrough = false

func _ready() -> void:
	get_viewport().transparent_bg = true
	_toggle_passthrough()
	
func _toggle_passthrough():
	passthrough = !passthrough
	if passthrough:
		DisplayServer.window_set_mouse_passthrough(PackedVector2Array([]))
	else:
		var window_size = Vector2(get_window().size)
		var clickable_size = window_size
		var center = window_size / 2
		var polygon = PackedVector2Array([
			center - clickable_size / 2,
			center + Vector2(clickable_size.x / 2, -clickable_size.y / 2),
			center + clickable_size / 2,
			center + Vector2(-clickable_size.x / 2, clickable_size.y / 2)
		])
		DisplayServer.window_set_mouse_passthrough(polygon)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_menu"):
		customization_menu. show()
	if event.is_action_pressed("ui_cancel") and visible:
		customization_menu.hide()
	if event.is_action_pressed("passthrough"):
		_toggle_passthrough()
