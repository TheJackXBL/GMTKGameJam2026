extends Node2D

@export var dayLength := 10.0

@onready var world = $World
@onready var dayManager = $DayManager
@onready var timer = $CanvasLayer/DayTimer
@onready var timerLabel = $CanvasLayer/TimerLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world.set_Day(dayManager.get_day())
	timer.start(dayLength)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var timerProgress = 1.0 - (timer.time_left / dayLength)
	world.set_dayProgress(timerProgress)
	
	timerLabel.text = "Day Timer: " + str(ceil(timer.time_left))


func _on_day_timer_timeout() -> void:
	if dayManager.currentDay + 1 >= dayManager.days.size():
		print("Game Complete!")
		return
#		TODO:Obviously will need to do an actual ending call here
	
	dayManager.set_tomorrow()

	world.set_Day(dayManager.get_day())

	timer.start()
