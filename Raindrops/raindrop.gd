extends RigidBody2D

@onready var streak_container = get_parent().get_node("StreakContainer")

var streak : Line2D
var streak_minDistance := 2.0

var last_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	streak = Line2D.new()
	streak.width = 8
	streak.default_color = Color.WHITE
	streak_container.add_child(streak)
	
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
