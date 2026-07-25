extends Node2D

signal startCountdown

@export var RaindropManager: Node2D

@export var race_camera: Camera2D

@export var canvas: CanvasLayer
@onready var finishLine = $"../FinishLine"

var score: int = 0
var races_won: int = 0
var races_played: int = 0

var selected_finish_position: int = 0
var selected_raindrop_finished: bool = false

signal score_changed(new_score)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_start_race_button_pressed() -> void:

	if RaindropManager.selected_raindrop != null:
		startCountdown.emit()
	
	races_played += 1
	finishLine.reset_race()


func _on_finish_line_winner_determined(winning_raindrop: Node2D) -> void:
	
	var winner_is_selected: bool = winning_raindrop.get("isSelected")
	

	
	if winner_is_selected:
		print("The selected raindrop won!")
	else:
		print("The selected raindrop did not win.")
	
	await race_camera.show_winner(winning_raindrop)

	get_tree().paused = false
	Engine.time_scale = 3.0

	var elapsed_time: float = 0.0
	var maximum_time: float = 3.0

	while elapsed_time < maximum_time and not selected_raindrop_finished:
		await get_tree().process_frame
		elapsed_time += get_process_delta_time()

	Engine.time_scale = 1.0

	update_score(true, selected_finish_position)

	RaindropManager.fade_remaining_raindrops()
	RaindropManager.prepare_and_spawn_raindrops()

	selected_raindrop_finished = false
	selected_finish_position = 0


func _on_canvas_layer_countdown_finished() -> void:
	print("GO appeared")
	start_race()

func start_race() -> void:
	RaindropManager.start_race()


func update_score(playedRace: bool, finishing_position: int) -> void:
	
	if playedRace:
		var points_earned: int = 0
		
		match finishing_position:
			1:
				points_earned = 100
				races_won += 1
			2:
				points_earned = 60
			3:
				points_earned = 40
			4:
				points_earned = 30
			5:
				points_earned = 20
			6:
				points_earned = 10
		
		score += points_earned
		
		score_changed.emit(score)
		
		if points_earned > 0:
			print("Finished position ", finishing_position, ". +", points_earned, " points")
		else:
			print("Selected raindrop did not finish in the top 6. No points.")
		
		print("Updated Score: ", score)
	else:
		pass #TODO: Shop logic


func _on_finish_line_raindrop_finished(raindrop: Node2D, position: int) -> void:
	
	if raindrop.get("isSelected"):
		selected_finish_position = position
		selected_raindrop_finished = true
		print("Selected raindrop finished in position ", position)
