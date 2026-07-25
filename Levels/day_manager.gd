extends Node

@export var days : Array[DayData]

var currentDay := 1

#Getters
func get_day() -> DayData:
	return days[currentDay-1] #This compensates for the array mismatch


#Setters
func set_tomorrow() -> void:
	currentDay += 1
