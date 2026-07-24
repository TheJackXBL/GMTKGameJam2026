extends Node2D

@onready var glass := $Glass
@onready var glassMat : ShaderMaterial = glass.material


func _ready() -> void:
	print(
		"Initial frost:",
		glassMat.get_shader_parameter("frostAmount")
	)


func set_dayProgress(progress : float) -> void:
	glassMat.set_shader_parameter(
		"frostAmount",
		1.0 - progress
	)


func set_frost(amount : float) -> void:
	glassMat.set_shader_parameter(
		"frostAmount",
		clampf(amount, 0.0, 1.0)
	)
