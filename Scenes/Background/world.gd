extends Node2D

@onready var sky = $Parallax2D/Sky
@onready var sky_sun = $Sun
@onready var background = $Parallax2D2/Background
@onready var background_sun = $Parallax2D2/SunBG
@onready var foreground = $Parallax2D3/Foreground
@onready var fog = $FogLayer

@onready var blue_car_sprite: Sprite2D = $WindowParent/Windowpngblue
@onready var yellow_car_sprite: Sprite2D = $WindowParent/Windowpngyellow
@onready var timer = %DayTimer

@onready var rain_noises: AudioStreamPlayer = $WorldBGNoises

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
	#print(progress)
	sky_sun.modulate.a = progress
	background_sun.modulate.a = progress
	fog.modulate.a = 1.0 - progress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_car_sprite()
	fade_in_rain_audio()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer.time_left <= 0.0:
		return
	
	var progress: float = 1.0 - (timer.time_left / timer.wait_time)
	yellow_car_sprite.modulate.a = progress

func reset_car_sprite():
	yellow_car_sprite.modulate.a = 0

func fade_in_rain_audio():
	rain_noises.volume_db = -40.0
	rain_noises.play()
	
	var tween := create_tween()
	tween.tween_property(rain_noises, "volume_db", -22.5, 1.25)
	

func _on_new_main_day_changing() -> void:
	reset_car_sprite()
