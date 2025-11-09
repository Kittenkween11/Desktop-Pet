extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D

var direction = Vector2.ZERO
var speed = 80.0

func _ready():
	var window_size = get_window().size
	position = window_size / 2
	
	sprite.visible = true
	sprite.play("idle")
	
	randomize()
	random_walk()

func _physics_process(_delta):
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
