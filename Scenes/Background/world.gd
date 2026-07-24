extends Node2D

@onready var sky = $Parallax2D/Sky
@onready var sky_sun = $Sun
@onready var background = $Parallax2D2/Background
@onready var background_sun = $Parallax2D2/SunBG
@onready var foreground = $Parallax2D3/Foreground
@onready var fog = $FogLayer

func set_Day(day : DayData) -> void:
	sky.texture = day.get_texture("Sky")
	sky_sun.texture = day.get_texture("Sky_Sun")
	background.texture = day.get_texture("BG")
	background_sun.texture = day.get_texture("BG_Sun")
	foreground.texture = day.get_texture("FG")
	
#	TODO: Finish wind system and then implement here
	#.min_speed = day.min_wind_speed
	#.max_speed = day.max_wind_speed
	#.spawn_chance = day.obstacle_chance

func set_dayProgress(progress : float):
	print(progress)
	sky_sun.modulate.a = progress
	background_sun.modulate.a = progress
	fog.modulate.a = 1.0 - progress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
