extends Node2D

@export var raindropScene : PackedScene

@export var maximumSpeed : int = 10

@export_range(0.0, 100000.0, 1.0)
var spawnLength : float = 1000.0

@export var spawnY : float = 0.0

@export_range(0, 10000, 1)
var raindropCount : int = 10

@export var spawnOnReady : bool = true

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	if spawnOnReady:
		spawn_raindrops(raindropScene, raindropCount)


func spawn_raindrops(scene : PackedScene, amount : int) -> void:

	var halfLength := spawnLength / 2.0

	for i in amount:

		var raindrop := scene.instantiate()

		var randomX := rng.randf_range(-halfLength, halfLength)

		raindrop.global_position = to_global(
			Vector2(randomX, spawnY)
		)

		add_child(raindrop)


func clear_raindrops() -> void:

	for child in get_children():

		child.queue_free()


func set_spawn_count(amount : int) -> void:
	raindropCount = amount


func set_spawn_width(width : float) -> void:
	spawnLength = width
