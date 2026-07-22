extends Node2D

@export var raindrop_object: PackedScene
@export var maximum_speed: int = 10

@export_range(0.0, 100000.0, 1.0) var spawn_length: float = 1000.0
@export var spawn_y: float = 0.0

@export_range(0, 10000, 1) var raindrop_count: int = 10
@export var spawn_on_ready: bool = true

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

func spawn_raindrops(raindrop_object: PackedScene, amount: int) -> void:

	var half_length: float = spawn_length / 2.0

	for i in range(amount):
		var raindrop_instance := raindrop_object.instantiate()
		add_child(raindrop_instance)

		var random_x := rng.randf_range(-half_length, half_length)
		var random_speed := rng.randi_range(0, maximum_speed)
		var random_angle := rng.randf_range(-20.0, 20.0)

		
		raindrop_instance.global_position = to_global(Vector2(random_x, spawn_y))


func _on_button_pressed() -> void:
	if spawn_on_ready:
		spawn_raindrops(raindrop_object, raindrop_count)
