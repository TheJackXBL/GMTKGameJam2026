extends Camera2D

@export var winner_zoom := Vector2(2.5, 2.5)
@export var zoom_in_duration := 0.5
@export var focus_duration := 1.5
@export var zoom_out_duration := 0.75

var starting_position: Vector2
var starting_zoom: Vector2
var sequence_running := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	starting_position = global_position
	starting_zoom = zoom


func show_winner(target: Node2D) -> void:
	if sequence_running:
		return
	
	sequence_running = true
	get_tree().paused = true
	
	await move_camera(target.global_position, winner_zoom, zoom_in_duration)
	
	await get_tree().create_timer(focus_duration,true).timeout
	
	await move_camera(starting_position, starting_zoom, zoom_out_duration)
	
	get_tree().paused = false
	sequence_running = false


func move_camera(target_position: Vector2,target_zoom: Vector2,duration: float) -> void:
	var tween := create_tween()
	
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "global_position", target_position, duration)
	
	tween.tween_property(self, "zoom", target_zoom, duration)
	
	await tween.finished
