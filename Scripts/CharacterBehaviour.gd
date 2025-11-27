extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var direction = Vector2.ZERO
var speed = 80.0
var half_extents = Vector2.ZERO

func _ready():
	var viewport_size = get_viewport_rect().size
	position = viewport_size / 2
	
	if collision_shape.shape is RectangleShape2D:
		half_extents = collision_shape.shape.extents
	elif collision_shape.shape is CircleShape2D:
		half_extents = Vector2(collision_shape.shape.radius, collision_shape.shape.radius)
	
	sprite.visible = true
	sprite.play("idle")
	
	randomize()
	random_walk()
	
func _physics_process(_delta):
	var new_position = position + Vector2(direction * speed * _delta)
	
	var viewport_size = get_viewport_rect().size # Use viewport size here too!
	
	var min_x = half_extents.x
	var min_y = half_extents.y
	
	var max_x = viewport_size.x - half_extents.x
	var max_y = viewport_size.y - half_extents.y
	
	new_position.x = clampf(new_position.x, min_x, max_x)
	new_position.y = clampf(new_position.y, min_y, max_y)
	
	position = new_position
	
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
		
func get_bounding_polygon() -> PackedVector2Array:
	var pos = global_position
	var half_w = half_extents.x
	var half_h = half_extents.y
	
	var top_left = pos + Vector2(-half_w, -half_h)
	var top_right = pos + Vector2(half_w, -half_h)
	var bottom_right = pos + Vector2(half_w, half_h)
	var bottom_left = pos + Vector2(-half_w, half_h)
	
	return PackedVector2Array([
		top_left,
		top_right,
		bottom_right,
		bottom_left
	])
	
func random_walk():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	if direction != Vector2.ZERO:
		sprite.play("walkSide")
	else:
		sprite.play("idle")
	
	await get_tree().create_timer(randf_range(6, 8)).timeout
	
	direction = Vector2.ZERO
	sprite.play("idle")
	
	await get_tree().create_timer(randf_range(2, 4)).timeout
	
	random_walk()

func move_to_position_target(target_pos: Vector2):
	direction = (target_pos - position).normalized()

func idle():
	sprite.stop()
	sprite.play("idle")
	print("IDLE")

# Customization callbacks
func _on_color_changed(color: Color):
	sprite.modulate = color
