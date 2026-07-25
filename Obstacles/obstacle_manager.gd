extends Node

@export var obstacles_per_day := 3

@export var leaf_scene : PackedScene
@export var bird_poop_scenes : Array[PackedScene]

@export var obstacle_container : Node2D
@export var day_manager : Node
@export var obstacle_spawnarea : Area2D

func _ready() -> void:
	day_manager.day_started.connect(spawn_day_obstacles)

func get_obstacle_scene() -> PackedScene:
	var day = day_manager.get_day()

	match day.BG_tag:
		"Field":
			return leaf_scene
		
		"Sea":
			return get_random_bird_poop()
		
		_:
			push_warning(
				"No obstacle assigned for BG_tag: %s" % day.BG_tag
			)
			return null

func get_random_bird_poop() -> PackedScene:
	if bird_poop_scenes.is_empty():
		push_warning("No bird poop scenes assigned!")
		return null

	return bird_poop_scenes[randi() % bird_poop_scenes.size()]

func spawn_obstacle() -> void:
	var scene := get_obstacle_scene()
	
	if scene == null:
		return
	
	var obstacle := scene.instantiate() as WindowObstacle
	
	obstacle.position = get_spawn_position()
	
	obstacle_container.add_child(obstacle)
	
	obstacle.setup()


func get_spawn_position() -> Vector2:
	var shape := obstacle_spawnarea.get_node("CollisionShape2D").shape as RectangleShape2D
	
	var half_size := shape.size / 2.0
	
	return obstacle_spawnarea.global_position + Vector2(
		randf_range(-half_size.x, half_size.x),
		randf_range(-half_size.y, half_size.y)
	)

func spawn_day_obstacles() -> void:
	var day = day_manager.get_day()
	var failures := 0

	for i in obstacles_per_day:
		var checks := 1 + failures
		var spawned := false
		
		for j in checks:
			if roll_obstacle_chance(day.obstacle_chance):
				spawn_obstacle()
				spawned = true
				break
			
			failures += 1
		
		if not spawned:
			continue

func clear_obstacles() -> void:
	for obstacle in obstacle_container.get_children():
		obstacle.clear()

func roll_obstacle_chance(chance: int) -> bool:
	return randi_range(1, 100) <= chance
