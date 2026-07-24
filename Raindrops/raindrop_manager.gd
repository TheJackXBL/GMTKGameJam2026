extends Node2D

@export var raindrop_scene: PackedScene

@export_range(0.0, 100000.0, 1.0)
var spawn_length: float = 1000.0

@export var spawn_y: float = 0.0

@export_range(0, 10000, 1)
var raindrop_count: int = 10

@export var spawn_on_ready := true


var rng := RandomNumberGenerator.new()


@onready var streak_container: Node2D = $"../StreakContainer"


func _ready() -> void:
	rng.randomize()

	if spawn_on_ready:
		spawn_raindrops(raindrop_count)



func spawn_raindrops(amount: int) -> void:

	var half_length := spawn_length / 2.0

	for i in amount:

		var drop := raindrop_scene.instantiate()

		drop.streak_container = streak_container

		var x := rng.randf_range(
			-half_length,
			half_length
		)

		drop.global_position = global_position + Vector2(
			x,
			spawn_y
		)

		add_child(drop)



func clear_raindrops() -> void:
	for drop in get_children():
		drop.queue_free()
