extends Node

@export var days : Array[DayData]

var currentDay := 0

func get_day() -> DayData:
	return days[currentDay]

func set_tomorrow() -> void:
	currentDay += 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
