extends Node2D

@export var RaindropManager: Node2D

@export var race_camera: Camera2D

@onready var finishLine = $"../FinishLine"

var score: int = 0
var races_won: int = 0
var races_played: int = 0

signal score_changed(new_score)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_race_button_pressed() -> void:
	races_played += 1
	finishLine.reset_race()


func _on_finish_line_winner_determined(winning_raindrop: Node2D) -> void:
	
	var winner_is_selected: bool = winning_raindrop.get("isSelected")
	
	update_score(true, winner_is_selected)
	
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

func update_score(playedRace: bool, won: bool) -> void:
	if playedRace:
		if won:
			score += 100
			races_won += 1
			print("Winner! +100 points")
		else:
			print("Lost race. No points.")
	else:
		pass #TODO: Shop logic
	
	score_changed.emit(score) #Hookup to Canvas
	print("Updated Score:", score)
