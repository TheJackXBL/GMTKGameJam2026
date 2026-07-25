extends Area2D

signal winner_determined(raindrop: Node2D)

@onready var race_manager: Node2D = %RaceManager

var winning_raindrop: RigidBody2D
var race_finished := false

@export var celebration_particles: PackedScene

func _ready() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	
	print("Groups: ", body.get_groups())
	
	if race_finished:
		return
	
	if not body.is_in_group("raindrops"):
		return
	
	race_finished = true
	winning_raindrop = body
	
	create_celebration(winning_raindrop.global_position)
	
	winner_determined.emit(winning_raindrop)

func create_celebration(position: Vector2) -> void:
	var particles := celebration_particles.instantiate() as GPUParticles2D
	
	get_tree().current_scene.add_child(particles)
	particles.global_position = position

func _on_start_race_button_pressed() -> void:
	race_finished = false
	winning_raindrop = null
