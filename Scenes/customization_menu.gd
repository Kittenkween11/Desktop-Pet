# CustomizationMenu.gd
extends Control

signal color_changed(color: Color)

@onready var color_picker = $VBoxContainer/Panel/ColorPickerButton
@onready var close_button = $VBoxContainer/Panel/Button
@onready var label = $VBoxContainer/Panel/Label

func _ready():
	# Connect signals
	if color_picker:
		color_picker.color_changed.connect(_on_color_changed)
		print("Color picker connected")
	else:
		push_error("ColorPickerButton not found at path: MarginContainer/VBoxContainer/Panel/ColorPickerButton")
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		close_button.text = "Close"  # Make sure button has text
		print("Close button connected")
	else:
		push_error("Button not found at path: MarginContainer/VBoxContainer/Panel/Button")
	
	if label:
		label.text = "Pet Customization"  # Set label text

func _on_color_changed(color: Color):
	print("Color changed to: ", color)
	color_changed.emit(color)

func _on_close_pressed():
	print("Close button pressed")
	hide()
