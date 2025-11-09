extends Control

signal color_changed(color: Color)

@onready var color_picker = $MarginContainer/VBoxContainer/Panel/ColorPickerButton
@onready var close_button = $MarginContainer/VBoxContainer/Panel/Button
@onready var label = $MarginContainer/VBoxContainer/Panel/Label

func _ready():
	# Connect ColorPicker
	if color_picker:
		color_picker.color_changed.connect(_on_color_changed)
		print("Color picker connected")
	else:
		push_error("ColorPickerButton not found at path: MarginContainer/VBoxContainer/Panel/ColorPickerButton")
	
	# Connect Close Button
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		close_button.text = "Ok"
		print("Close button connected")
	else:
		push_error("Button not found at path: MarginContainer/VBoxContainer/Panel/Button")
	
	# Set Label
	if label:
		label.text = "Customization"
	
	# Make sure menu starts hidden
	hide()

func _on_color_changed(color: Color):
	print("Color changed to: ", color)
	emit_signal("color_changed", color)

func _on_close_pressed():
	hide()

func _input(event):
	# Close menu on Esc or "ui_cancel"
	if event.is_action_pressed("ui_cancel") and visible:
		hide()
		get_viewport().set_input_as_handled()
