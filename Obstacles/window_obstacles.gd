extends StaticBody2D
class_name WindowObstacle

@export var min_scale := 0.4
@export var max_scale := 1.0

@export var min_rotation := -30.0
@export var max_rotation := 30.0


func setup() -> void:
	randomize_size()
	randomize_rotation()


func randomize_size() -> void:
	var random_size := randf_range(min_scale, max_scale)
	scale = Vector2.ONE * random_size


func randomize_rotation() -> void:
	rotation_degrees = randf_range(
		min_rotation,
		max_rotation
	)

func clear():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
	tween.finished.connect(queue_free)
