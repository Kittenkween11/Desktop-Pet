# CustomizationMenu.gd
extends Control

signal color_changed(color: Color)
var character_node: Node2D = null

@onready var color_picker = $VBoxContainer/Panel/ColorPickerButton
@onready var close_button = $VBoxContainer/Panel/ConfirmColor
@onready var passthrough_button = $VBoxContainer/Panel/PassthroughButton
@onready var label = $VBoxContainer/Panel/Label


func _ready():
	if color_picker:
		color_picker.color_changed.connect(_on_color_changed)
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		close_button.text = "Close"
	
	if passthrough_button:
		passthrough_button.pressed.connect(_on_passthrough_pressed)
	
	if label:
		label.text = "Customization"
	
func set_character(character: Node2D):
	character_node = character
	
func _on_color_changed(color: Color):
	if character_node:
		var sprite = character_node.get_node("AnimatedSprite2D")
		if sprite:
			sprite.modulate = color
		
	color_changed.emit(color)
	
func _on_close_pressed():
	print("Close button pressed")
	hide()

func _on_passthrough_pressed():
	# Check the current state and toggle it
	if mouse_filter == Control.MOUSE_FILTER_PASS:
		# If currently passing through, set it to stop/block
		mouse_filter = Control.MOUSE_FILTER_STOP
		print("Passthrough OFF (Mouse Filter: STOP)")
	else:
		# If currently stopping/blocking, set it to pass through
		mouse_filter = Control.MOUSE_FILTER_PASS
		print("Passthrough ON (Mouse Filter: PASS)")
