extends Node2D

@onready var glass := $Glass
@onready var glassMat : ShaderMaterial = glass.material

@export var maxFrost := 3.0


func _ready() -> void:
	print(
		"Initial frost:",
		glassMat.get_shader_parameter("frostAmount")
	)


func set_dayProgress(progress : float) -> void:
	glassMat.set_shader_parameter(
		"frostAmount",
		maxFrost - (progress * maxFrost)
	)


func set_frost(amount : float) -> void:
	glassMat.set_shader_parameter(
		"frostAmount",
		clampf(amount, 0.0, maxFrost)
	)
