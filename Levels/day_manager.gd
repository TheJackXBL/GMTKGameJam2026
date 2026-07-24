extends Node

@export var days : Array[DayData]

var currentDay := 0

#Getters
func get_day() -> DayData:
	return days[currentDay]


#Setters
func set_tomorrow() -> void:
	currentDay += 1
