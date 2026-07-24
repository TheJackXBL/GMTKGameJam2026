extends Resource
class_name DayData

@export var dayNum : int

@export var BG_tag := "Field"

#Weather
@export var min_wind_speed := -100.0
@export var max_wind_speed := 100.0

#Raindrop Stats

@export var min_weight := 1.0
@export var max_weight := 5.0

@export var min_friendliness := 1.0
@export var max_friendliness := 5.0

@export var min_slipperiness := 1.0
@export var max_slipperiness := 5.0

#Obstacles
@export_range(0,100)
var obstacle_chance := 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
