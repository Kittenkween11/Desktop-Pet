extends Node2D

@onready var customization_menu = $CustomizationMenu

func _ready() -> void:
	customization_menu.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_menu"):
		customization_menu. show()
	if event.is_action_pressed("ui_cancel") and visible:
		customization_menu.hide()
