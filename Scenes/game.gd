extends Node2D

@export var dayLength := 10.0

@onready var world = $World
@onready var dayManager = $DayManager
@onready var timer = $CanvasLayer/DayTimer
@onready var timerLabel = $CanvasLayer/TimerLabel
@onready var canvas = $CanvasLayer
@onready var window =$Window

var dayStarted := false
var dayFinished := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_day(dayManager.get_day())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var timerProgress := 0.0
	timerProgress = set_timerProgress() 

	world.set_dayProgress(timerProgress)
	window.set_dayProgress(timerProgress)
	
	timerLabel.text = "Day Timer: " + str(ceil(timer.time_left))

func change_day():
	print("Changing day...")
	
	await canvas.fadeIn()
	print("Fade complete")
	
	dayManager.set_tomorrow()
	start_day(dayManager.get_day())
	
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
	play_cutscene(dayManager.currentDay, "day_end")

func start_day(day: DayData) -> void:
	dayStarted = false
	dayFinished = false
	
	world.set_Day(day)
	play_cutscene(dayManager.currentDay, "day_start")

func begin_game() -> void:
	dayStarted = true
	timer.start(dayLength)


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
		
	DialogueManager.show_example_dialogue_balloon(
		dialogue,
		tag,
		[
			{ "game": self }
		]
	)
