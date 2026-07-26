extends Node

@export var boost_count := 15

@export var rain_drop_scene: PackedScene
@export var boost_container: Node2D
@export var spawn_area: Area2D

func _ready() -> void:
	spawn_boosts()

func spawn_boosts() -> void:
	for i in boost_count:
		spawn_boost()

func spawn_boost() -> void:
	var boost = rain_drop_scene.instantiate()
	boost.position = get_spawn_position()
	boost_container.add_child(boost)

func get_spawn_position() -> Vector2:
	var shape := spawn_area.get_node("CollisionShape2D").shape as RectangleShape2D
	var half_size := shape.size / 2.0
	return spawn_area.global_position + Vector2(
		randf_range(-half_size.x, half_size.x),
		randf_range(-half_size.y, half_size.y)
	)
