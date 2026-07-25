extends StaticBody2D
class_name WindowObstacle

@onready var sprite := $Sprite2D
@onready var obstacleMat : ShaderMaterial = sprite.material

@export var maxFrost := 0.8

@export var min_scale := 0.4
@export var max_scale := 1.0

@export var min_rotation := -30.0
@export var max_rotation := 30.0


func setup() -> void:
	randomize_size()
	randomize_rotation()
	
	set_frost(maxFrost)

func set_dayProgress(progress: float) -> void:
	var adjustedProgress := pow(clampf(progress, 0.0, 1.0), 2.0)
	
	obstacleMat.set_shader_parameter(
		"frostAmount",
		maxFrost * (1.0 - adjustedProgress)
	)

func set_frost(amount : float) -> void:
	obstacleMat.set_shader_parameter(
		"frostAmount",
		clampf(amount, 0.0, maxFrost)
	)

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
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.finished.connect(queue_free)
