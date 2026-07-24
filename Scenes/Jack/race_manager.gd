extends Node2D

@export var RaindropManager: Node2D

@export var race_camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_race_button_pressed() -> void:
	pass # Replace with function body.


func _on_finish_line_winner_determined(winning_raindrop: Node2D) -> void:
	
	var winner_is_selected: bool = winning_raindrop.get("isSelected")
	
	if winner_is_selected:
		print("The selected raindrop won!")
	else:
		print("The selected raindrop did not win.")
	
	await race_camera.show_winner(winning_raindrop)
	
	#TODO - Speed up race, clear raindrops, spawn new raindrops
	
	get_tree().paused = false
	Engine.time_scale = 3.0
	
	await get_tree().create_timer(3.0, true, false, true).timeout
	
	Engine.time_scale = 1.0
	
	RaindropManager.fade_remaining_raindrops()
	
	RaindropManager.prepare_and_spawn_raindrops()
