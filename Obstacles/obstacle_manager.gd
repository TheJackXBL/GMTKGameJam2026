extends Node

@export var obstacle_scene : PackedScene
@export var obstacle_container : Node2D
@export var day_manager : Node

@export var leaf_data : ObstacleData
@export var bird_poop_data : ObstacleData

func get_obstacle_data() -> ObstacleData:
	var day = day_manager.get_day()
	
	match day.BG_tag:
		"Field":
			return leaf_data
			
		"Sea":
			return bird_poop_data
			
		_:
			push_warning("No obstacle assigned for day tag: %s" % day.tag)
			return null

func try_spawn_obstacle() -> void:
	var day = day_manager.get_day()
	
	if randi_range(1, 100) > day.obstacle_chance:
		return
		
	spawn_obstacle()

func spawn_obstacle() -> void:
	var data := get_obstacle_data()

	if data == null:
		return

	var obstacle = obstacle_scene.instantiate() as WindowObstacle
	obstacle.data = data

	obstacle_container.add_child(obstacle)
	obstacle.begin()
