extends Node2D

signal dayChanging
signal score_changed(updated_score)
signal smack_performed(position)

@export var dayLength := 10.0
@export var smackCost := 50
@export var smack_effect_scene: PackedScene

@onready var smack_button = $CanvasLayer/SmackButton
@onready var smack_effect_container = $SmackEffectContainer
@onready var world = $World
@onready var dayManager = $DayManager
@onready var timer = $CanvasLayer/DayTimer
@onready var timerLabel = $CanvasLayer/TimerLabel
@onready var canvas = $CanvasLayer
@onready var window = $Window
@onready var RaindropManager: Node2D = $Window/RaindropManager
@onready var music_player = $MusicPlayer
@onready var obstacleManager = $ObstacleManager
@onready var race_manager = $RaceManager

var dayStarted := false
var dayFinished := false

var timerActive := false

var current_score := 0
var smackArmed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	race_manager.score_changed.connect(_on_score_changed)
	score_changed.connect(canvas.update_score)
	smack_performed.connect(canvas.play_smack_effect)
	start_day(dayManager.get_day())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var timerProgress := 0.0
	timerProgress = set_timerProgress() 

	world.set_dayProgress(timerProgress)
	window.set_dayProgress(timerProgress)
	obstacleManager.set_dayProgress(timerProgress)
	
	timerLabel.text = str(int(timer.time_left))

func change_day():
	print("Changing day...")
	
	await canvas.fadeIn()
	print("Fade complete")
	obstacleManager.clear_obstacles()
	
	dayManager.set_tomorrow()
	start_day(dayManager.get_day())
	
	dayChanging.emit()
	
	await get_tree().create_timer(0.2).timeout
	
	await canvas.fadeOut()

func set_timerProgress() -> float:
	if dayFinished:
		return 1.0
	elif dayStarted:
		return 1.0 - (timer.time_left / dayLength)
	else:
		return 0.0

func _on_day_timer_timeout() -> void:
	dayFinished = true
	
	if RaindropManager.race_started == false:
		go_to_day_end_dialogue()
		RaindropManager.fade_remaining_raindrops()
	

func go_to_day_end_dialogue() -> void:
	play_cutscene(dayManager.currentDay, "day_end")
	
	

func start_day(day: DayData) -> void:
	dayStarted = false
	dayFinished = false
	
	timer.start(dayLength)
	timer.paused = true
	
	world.set_Day(day)
	play_cutscene(dayManager.currentDay, "day_start")
	
	RaindropManager.prepare_and_spawn_raindrops()

func begin_game() -> void:
	dayStarted = true
	timer.paused = false
	timer.start(dayLength)
	music_player.play()


func end_day():
	if dayManager.currentDay >= dayManager.days.size():
		print("Game Complete!")
		return
	
	change_day()

func play_cutscene(day: int, tag: String):
	var dialogue_path = "res://Dialogue/Dialog_Day%d.dialogue" % day
	
	var dialogue = load(dialogue_path)
	
	if dialogue == null:
		push_error("Could not load dialogue: " + dialogue_path)
		return
		
	DialogueManager.show_dialogue_balloon(
		dialogue,
		tag,
		[
			{ "game": self }
		]
	)

func play_smack_effect(position: Vector2):
	var effect = smack_effect_scene.instantiate()
	
	effect.global_position = position
	smack_effect_container.add_child(effect)
	
	effect.play_smack()

#SCORE KEEPING
func add_score(amount:int) -> void:
	current_score += amount
	score_changed.emit(current_score)

func _on_score_changed(new_score:int) -> void:
	current_score = new_score

func can_afford(cost:int) -> bool:
	return current_score >= cost

func spend_score(cost:int) -> bool:
	return race_manager.spend_score(cost)

func set_smack_armed(value: bool):
	smackArmed = value

func _on_smack_button_pressed() -> void:
	if not can_afford(smackCost):
		print("Not enough score")
		return
	
	set_smack_armed(!smackArmed)

func set_smack_button_visible(value: bool):
	smack_button.visible = value

func smack_obstacle(position: Vector2):
	if spend_score(smackCost):
		smack_performed.emit(position)

func _unhandled_input(event: InputEvent) -> void:
	if not smackArmed:
		return
	
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		var mouse_position := get_global_mouse_position()
		
		var smack_position = obstacleManager.smack_closest(mouse_position)

		if smack_position != Vector2.ZERO:
			if spend_score(smackCost):
				smack_performed.emit(smack_position)
		set_smack_armed(false)

func use_smack(mouse_position: Vector2) -> void:

	if !spend_score(smackCost):
		set_smack_armed(false)
		return

	obstacleManager.smack_closest(mouse_position)

	set_smack_armed(false)
