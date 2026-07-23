extends Area2D

@export var race_camera: Camera2D

var winning_raindrop: RigidBody2D
var race_finished := false


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
	
	var winner_is_selected: bool = winning_raindrop.get("isSelected")
	
	if winner_is_selected:
		print("The selected raindrop won!")
	else:
		print("The selected raindrop did not win.")
	
	await race_camera.show_winner(winning_raindrop)


func _on_start_race_button_pressed() -> void:
	race_finished = false
	winning_raindrop = null
