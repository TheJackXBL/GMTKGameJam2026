extends Area2D

signal winner_determined(winning_raindrop: Node2D)
signal raindrop_finished(raindrop: Node2D, position: int)

var finished_raindrops: Array[Node2D] = []

@onready var race_manager: Node2D = %RaceManager

var winning_raindrop: RigidBody2D
var race_finished := false

@export var celebration_particles: PackedScene
@export var finish_position_label: PackedScene

func _ready() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	
	if not body.is_in_group("raindrops"):
		return
	
	if body in finished_raindrops:
		return
	
	finished_raindrops.append(body)
	
	race_finished = true
		
	var finishing_position: int = finished_raindrops.size()
	
	create_position_label(body.global_position, finishing_position)
	
	raindrop_finished.emit(body, finishing_position)
	
	if finishing_position == 1:
		create_celebration(body.global_position)
		winner_determined.emit(body)


func create_celebration(position: Vector2) -> void:
	var particles := celebration_particles.instantiate() as GPUParticles2D
	
	get_tree().current_scene.add_child(particles)
	particles.global_position = position

func create_position_label(finish_position: Vector2,placement: int) -> void:
	var position_label := finish_position_label.instantiate()
	get_tree().current_scene.add_child(position_label)
	
	position_label.global_position = finish_position
	position_label.global_position.x -= 25.0
	position_label.global_position.y += 25.0
	
	position_label.display_position(placement)

func reset_race() -> void:
	race_finished = false
	winning_raindrop = null
	finished_raindrops.clear()
