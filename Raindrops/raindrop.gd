extends RigidBody2D

@onready var streak_container = get_parent().get_node("StreakContainer")

var streak : Line2D
@export var streak_width := 8.0
@export var streak_minDistance := 2.0

var last_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	streak = Line2D.new()
	
	#Varying width code
	streak.width = streak_width #TODO: streak.width = radius * variance * 1.5
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.2))
	streak.width_curve = curve
	
	#Rounded Edges, future proofing for when they wiggle waggle
	streak.begin_cap_mode = Line2D.LINE_CAP_ROUND
	streak.end_cap_mode = Line2D.LINE_CAP_ROUND
	streak.joint_mode = Line2D.LINE_JOINT_ROUND
	
	streak.default_color = Color.WHITE
	#TODO: Replace above line with texture below
#	streak.texture = preload("res://Textures/waterStreak.png")
#	streak.texture_mode = Line2D.LINE_TEXTURE_TILE
	
	streak.modulate.a = 0.5
	
	#streak shader
	var shader = load("res://Scenes/Car/waterStreak.gdshader")
	streak.material = ShaderMaterial.new()
	streak.material.shader = shader
	
	streak_container.add_child(streak)
	
	if global_position.distance_to(last_position) > streak_minDistance:
		streak.add_point(
			streak.to_local(global_position)
		)
		last_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if global_position.distance_to(last_position) > 2:
		streak.add_point(
			streak.to_local(global_position)
		)
		last_position = global_position
