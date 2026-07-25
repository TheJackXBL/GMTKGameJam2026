class_name Raindrop
extends RigidBody2D

signal raindropSelected(raindrop: Node2D)
signal raindropStatsGenerated(speed: int, angle: float, weight: int, friendliness: int, slipperiness: int)

@export var isSelected: bool = false
@export var raindropName: String = "Dave"
@export var weightStat: int
@export var friendlinessStat: int
@export var slipperinessStat: int

@onready var streak_container: Node2D = get_parent().get_node("StreakContainer")
@onready var raindrop_sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var raindrop_ui: Control = $Node2D/RaindropInfoUI
const STREAK_SHADER := preload("res://Raindrops/raindrop_streak.gdshader")


#Drop size
@export var radius := 3.0
@export var starting_radius := 3.0

#Movement
@export var gravity_force := 100.0 # The downwards force being applied to the raindrop
@export var drag_strength := 1.8 # The resisting force to prevent the raindrop from accelerating too quickly, increase to slow acceleration
@export var maximum_speed := 400.0 # Hard cap on speed so we can incorporate it into stats
@export var acceleration_ramp_time := 3.0 # New variable to adjust the acceleration to make the stat more prominent

#Surface tension (icl hard to test this without obstacles or something that will decelerate the raindrop)
@export var adhesion_force := 100.0 # How sticky raindrops are in general
@export var minimum_moving_speed := 2.0 # If the raindrop goes below this speed, it attempts to stick
@export var sticking_delay := 0.3

#Sideways movement
@export var sideways_force := 30.0 # Adds randomness to the movement of the raindrops to simulate how it runs down a car window, could increase this for a wind ability? 
@export var direction_change_speed := 2.0 # How often bends happen

#Sprite stretching
@export var maximum_stretch := 1.0 # Stretching of the sprite, we'll need to make it look more seamless with the trail but I presume that's a shader thing? 
@export var stretch_speed := 3.0 # Speed at which the sprite stretches at

#Streaks / trails
@export var width_curve := Curve.new()
@export var streak_width_multiplier := 0.7 # Larger raindrops produce wider trails
@export var streak_minDistance := 3.0 #Minimum distance between points on the trail, to prevent poor performance

@export_category("Streak Riding")
@export var streak_ride_speed := 250.0
@export var streak_detection_distance := 8.0
@export var streak_detection_interval := 0.05

@export var escape_attempt_interval := 0.5
@export_range(0.0, 1.0) var initial_escape_chance := 0.05
@export_range(0.0, 1.0) var escape_chance_increase := 0.08
@export_range(0.0, 1.0) var maximum_escape_chance := 0.8
@export var escape_push_strength := 100.0
@export var streak_reentry_cooldown := 0.4

var is_riding_streak := false
var ridden_streak: Line2D
var last_ridden_streak: Line2D

var ridden_segment_index := 0
var ridden_segment_distance := 0.0

var current_escape_chance := 0.0
var escape_attempt_timer := 0.0
var streak_detection_timer := 0.0
var reentry_cooldown_timer := 0.0

var streak: Line2D
var last_streak_position: Vector2

var is_sliding := false
var is_being_absorbed := false # When raindrops merge, prevents code from getting angry
var time_below_minimum_speed := 0.0 # If the raindrop is going too slow for too long, it attempts to stick to the glass

var adhesion_multiplier := 1.0 # Slipperyness stat, better slippy stats means lower multiplier

var original_sprite_scale: Vector2 # Starting size of sprite

var movement_noise := FastNoiseLite.new() # Found cool noise generator!
var noise_offset := 0.0 # Keeps noise varied

var initial_speed: int = 3
var initial_angle: float = 0.0
var race_active: bool = false
var racing_time:= 0.0 #duration of race so far

func _ready() -> void:
	
	fade_in_drop()
	
	body_entered.connect(_on_body_entered)
	
	raindrop_ui.hide()
	
	original_sprite_scale = raindrop_sprite.scale
	last_streak_position = global_position
	
	#adhesion_multiplier = STAT OF RAINDROP
	
	# Each drop has a different path based on noise
	movement_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	movement_noise.frequency = 0.5
	movement_noise.seed = randi()
	
	# Prevents the collision shape from being shared between drops
	if collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
	
	create_streak()
	update_drop_size()
	
	if should_start_sliding():
		start_sliding()
	else:
		stop_sliding()

func setup_race_data(new_name: String, new_speed: int, new_angle: float, weight: int, friendliness: int, slipperiness: int) -> void:
	
	raindropName = new_name
	initial_speed = new_speed
	initial_angle = new_angle
	weightStat = weight
	friendlinessStat = friendliness
	slipperinessStat = slipperiness
	
	raindropStatsGenerated.emit(raindropName, initial_speed, initial_angle, weightStat, friendlinessStat, slipperinessStat)

	#rotation_degrees = travel_angle

# Freezes raindrops in place
func prepare_for_race() -> void:
	race_active = false

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	freeze = true
	sleeping = true

func begin_racing() -> void:
	race_active = true
	racing_time = acceleration_ramp_time / 2

	freeze = false
	sleeping = false

	var direction := Vector2.DOWN.rotated(deg_to_rad(initial_angle))
	linear_velocity = direction * initial_speed

func _physics_process(delta: float) -> void:
	
	if not race_active:
		return
	
	if reentry_cooldown_timer > 0.0:
		reentry_cooldown_timer -= delta

	if is_riding_streak:
		update_streak_riding(delta)
		update_drop_shape(delta)

		if global_position.distance_to(last_streak_position) >= streak_minDistance:
			add_streak_point()

		return

	streak_detection_timer -= delta

	if streak_detection_timer <= 0.0:
		streak_detection_timer = streak_detection_interval
		try_find_streak()
	
	update_drop_shape(delta)
	
	if not is_sliding:
		return
	
	if global_position.distance_to(last_streak_position) >= streak_minDistance:
		add_streak_point()
	
	#Allowing slow drops to stick to the glass,
	if linear_velocity.length() < minimum_moving_speed:
		time_below_minimum_speed += delta
		
		if time_below_minimum_speed >= sticking_delay:
			try_sticking()
	else:
		time_below_minimum_speed = 0.0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	if not race_active:
		return
	
	if is_riding_streak:
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		return
	
	if not is_sliding:
		return
	
	racing_time += state.step
	
	noise_offset += state.step * direction_change_speed # step is the Rigidbody's version of delta
	
	var size_factor := clampf(radius / starting_radius, 0.4, 2.5) # bigger raindrops move faster by a significant factor, buffs merged raindrops
	var sideways_direction := movement_noise.get_noise_1d(noise_offset) # -1 is left, 1 is right
	
	var acceleration_multiplier := get_acceleration_multiplier()
	var acceleration_ramp := clampf(racing_time / acceleration_ramp_time, 0.0, 1.0)
	
	# Pulls the raindrop down the window
	var downward_force := Vector2.DOWN * gravity_force * mass * (size_factor / 1.5) * acceleration_multiplier * acceleration_ramp
	
	# Makes the drop gradually wander from side to side for randomness
	var horizontal_force := Vector2.RIGHT * sideways_direction * sideways_force * mass
	
	#Applying drag prevents the drop from accelerating forever, applies in the opposite direction of travel
	var drag_force := -state.linear_velocity * drag_strength * mass * acceleration_multiplier
	
	#Applies total of forces to raindrop
	state.apply_central_force(downward_force + horizontal_force + drag_force)
	
	# Raindrop weight stat affects max speed
	var effective_maximum_speed := maximum_speed * get_weight_multiplier()
	
	var current_speed = state.linear_velocity.length()
	
	if current_speed > effective_maximum_speed:
		state.linear_velocity = state.linear_velocity.normalized() * effective_maximum_speed
	
	if state.linear_velocity.length_squared() > 0.1:
		var target_rotation := state.linear_velocity.angle() - PI / 2.0
		raindrop_sprite.rotation = lerp_angle(raindrop_sprite.rotation, target_rotation, 0.075)

func get_weight_multiplier() -> float:
	var weight_multiplier := remap(
		clampf(weightStat, 1, 10),
		1.0,
		10.0,
		1.0,
		2.0
	)

	return weight_multiplier

func get_friendliness_multiplier() -> float:
	return remap(
		clampf(friendlinessStat, 1, 10),
		1.0,
		10.0,
		0.8,
		1.7
	)

func get_acceleration_multiplier() -> float:
	return remap(
		clampf(slipperinessStat, 1, 10),
		1.0,
		10.0,
		0.8,
		1.7
	)

func create_streak() -> void:
	streak = Line2D.new()
	
	streak.width_curve = width_curve
	
	#Rounded Edges, future proofing for when they wiggle waggle
	streak.begin_cap_mode = Line2D.LINE_CAP_ROUND
	streak.end_cap_mode = Line2D.LINE_CAP_ROUND
	streak.joint_mode = Line2D.LINE_JOINT_ROUND
	
	streak.default_color = Color.WHITE
	
	
	
	#TODO: Replace above line with texture below
#	streak.texture = preload("res://Textures/waterStreak.png")
#	streak.texture_mode = Line2D.LINE_TEXTURE_TILE

	streak.modulate.a = 1
	
	#Streak shader
	var streak_material := ShaderMaterial.new()
	streak_material.shader = STREAK_SHADER
	streak.material = streak_material
	
	streak.z_index = 2
	
	streak_container.add_child(streak)

# Made adding streak point into function to keep things simple
func add_streak_point() -> void: 
	streak.add_point(streak.to_local(global_position))
	last_streak_position = global_position

func try_find_streak() -> void:
	if is_riding_streak:
		return

	for possible_streak in streak_container.get_children():
		if possible_streak is not Line2D:
			continue

		var line := possible_streak as Line2D

		if line == streak:
			continue

		if line == last_ridden_streak and reentry_cooldown_timer > 0.0:
			continue

		if line.get_point_count() < 2:
			continue

		if try_attach_to_streak(line):
			return


func try_attach_to_streak(line: Line2D) -> bool:
	var closest_distance := INF
	var closest_segment := -1
	var closest_segment_distance := 0.0

	for point_index in range(line.get_point_count() - 1):
		var segment_start := line.to_global(line.get_point_position(point_index))
		var segment_end := line.to_global(line.get_point_position(point_index + 1))

		var closest_point := Geometry2D.get_closest_point_to_segment(
			global_position,
			segment_start,
			segment_end
		)

		var distance_to_streak := global_position.distance_to(closest_point)

		if distance_to_streak >= closest_distance:
			continue

		closest_distance = distance_to_streak
		closest_segment = point_index
		closest_segment_distance = segment_start.distance_to(closest_point)

	var required_distance := streak_detection_distance + radius

	if closest_segment == -1 or closest_distance > required_distance:
		return false

	begin_streak_riding(
		line,
		closest_segment,
		closest_segment_distance
	)

	return true

func begin_streak_riding(
	line: Line2D,
	segment_index: int,
	segment_distance: float
) -> void:
	is_riding_streak = true
	ridden_streak = line
	ridden_segment_index = segment_index
	ridden_segment_distance = segment_distance

	current_escape_chance = initial_escape_chance
	escape_attempt_timer = escape_attempt_interval

	is_sliding = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = false

	move_to_current_streak_position()


func update_streak_riding(delta: float) -> void:
	if not is_instance_valid(ridden_streak):
		stop_streak_riding(false)
		return

	if ridden_streak.get_point_count() < 2:
		stop_streak_riding(false)
		return

	advance_along_streak(streak_ride_speed * get_weight_multiplier() * delta)

	escape_attempt_timer -= delta

	if escape_attempt_timer <= 0.0:
		escape_attempt_timer = escape_attempt_interval
		attempt_streak_escape()


func advance_along_streak(distance_to_move: float) -> void:
	while distance_to_move > 0.0:
		if ridden_segment_index >= ridden_streak.get_point_count() - 1:
			stop_streak_riding(false)
			return

		var segment_start := get_ridden_point_global(ridden_segment_index)
		var segment_end := get_ridden_point_global(ridden_segment_index + 1)
		var segment_length := segment_start.distance_to(segment_end)

		if segment_length <= 0.001:
			ridden_segment_index += 1
			ridden_segment_distance = 0.0
			continue

		var remaining_segment_distance := segment_length - ridden_segment_distance

		if distance_to_move < remaining_segment_distance:
			ridden_segment_distance += distance_to_move
			distance_to_move = 0.0
		else:
			distance_to_move -= remaining_segment_distance
			ridden_segment_index += 1
			ridden_segment_distance = 0.0

	move_to_current_streak_position()


func move_to_current_streak_position() -> void:
	if ridden_segment_index >= ridden_streak.get_point_count() - 1:
		return

	var segment_start := get_ridden_point_global(ridden_segment_index)
	var segment_end := get_ridden_point_global(ridden_segment_index + 1)
	var segment_direction := segment_start.direction_to(segment_end)
	var segment_length := segment_start.distance_to(segment_end)

	ridden_segment_distance = minf(
		ridden_segment_distance,
		segment_length
	)

	global_position = (
		segment_start
		+ segment_direction * ridden_segment_distance
	)

	if segment_direction.length_squared() > 0.0:
		var target_rotation := segment_direction.angle() - PI / 2.0
		raindrop_sprite.rotation = lerp_angle(
			raindrop_sprite.rotation,
			target_rotation,
			0.15
		)


func get_ridden_point_global(point_index: int) -> Vector2:
	return ridden_streak.to_global(
		ridden_streak.get_point_position(point_index)
	)

func attempt_streak_escape() -> void:
	if randf() <= current_escape_chance:
		stop_streak_riding(true)
		return

	current_escape_chance = minf(
		current_escape_chance + (escape_chance_increase / get_friendliness_multiplier()),
		maximum_escape_chance
	)

func stop_streak_riding(escaped: bool) -> void:
	if not is_riding_streak:
		return

	var exit_direction := get_current_streak_direction()

	last_ridden_streak = ridden_streak
	ridden_streak = null
	is_riding_streak = false

	reentry_cooldown_timer = streak_reentry_cooldown
	current_escape_chance = initial_escape_chance
	escape_attempt_timer = 0.0

	is_sliding = true
	sleeping = false

	linear_velocity = exit_direction * streak_ride_speed

	if escaped:
		var perpendicular := Vector2(
			-exit_direction.y,
			exit_direction.x
		)

		if randf() < 0.5:
			perpendicular = -perpendicular

		linear_velocity += perpendicular * escape_push_strength


func get_current_streak_direction() -> Vector2:
	if not is_instance_valid(ridden_streak):
		return Vector2.DOWN

	if ridden_segment_index >= ridden_streak.get_point_count() - 1:
		return Vector2.DOWN

	var segment_start := get_ridden_point_global(ridden_segment_index)
	var segment_end := get_ridden_point_global(ridden_segment_index + 1)
	var direction := segment_start.direction_to(segment_end)

	if direction.length_squared() <= 0.001:
		return Vector2.DOWN

	return direction

# bool function that determines if the raindrop should slide
func should_start_sliding() -> bool:
	var gravitational_pull := mass * gravity_force
	var adhesion := get_effective_adhesion()
	
	return gravitational_pull > adhesion

#Small drops are harder to pull away from the glass, will be useful when applying weight stat
func get_effective_adhesion() -> float:
	
	return adhesion_force * adhesion_multiplier / maxf(radius, 1.0)

#GO RAINDROP GO
func start_sliding() -> void:
	if is_sliding:
		return
	
	is_sliding = true
	sleeping = false
	time_below_minimum_speed = 0.0
	
	add_streak_point()

# Stops all velocity of the raindrop and puts it to sleep
func stop_sliding() -> void:
	is_sliding = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = true

# Attempts to have to the raindrop stick to the window
func try_sticking() -> void:
	var gravitational_pull := mass * gravity_force
	
	var random_stick_chance := randi_range(1, 3) # 1 in 3 chance to stick means raindrops aren't likely to get stuck for long
	
	if (gravitational_pull < get_effective_adhesion()) && random_stick_chance != 1:
		stop_sliding()
	else:
		time_below_minimum_speed = 0.0

# Stretches the raindrop sprite (does not stretch collision to save on processing)
func update_drop_shape(delta: float) -> void:
	
	var size_scale := radius / starting_radius
	var speed_ratio := clampf(linear_velocity.length() / (get_weight_multiplier() * maximum_speed), 0.0, 1.0) # 0 = stationary, 1 = max speed
	
	# Stretching faster drops downwards
	var stretch_amount := speed_ratio * maximum_stretch
	
	var stretch_scale := Vector2(1.0 - stretch_amount * 0.35, 1.0 + stretch_amount) # Slightly narrower, but way more stretched vertically
	
	var target_scale := original_sprite_scale * size_scale * stretch_scale
	var interpolation := 1.0 - exp(-stretch_speed * delta)
	
	raindrop_sprite.scale = raindrop_sprite.scale.lerp(target_scale,interpolation)

# calculates mass of raindrop based on size
func update_drop_size() -> void:
	mass = maxf(radius * radius * 0.01, 0.1)
	
	# Increases collision radius of raindrop after merging
	if collision_shape.shape is CircleShape2D:
		var circle_shape := collision_shape.shape as CircleShape2D
		circle_shape.radius = radius
	
	if is_instance_valid(streak):
		streak.width = radius * streak_width_multiplier

func _on_body_entered(body: Node) -> void:
	
	if body.is_in_group("death_zone"):
		remove_drop()
	
	if body is not Raindrop:
		return
	
	var other_drop := body as Raindrop
	
	if other_drop == self:
		return
	
	try_merge(other_drop)


func try_merge(other_drop: Raindrop) -> void:
	if is_being_absorbed or other_drop.is_being_absorbed: # to prevent loops / crashes
		return
	
	# Makes the larger drop absorb the smaller drop
	if radius >= other_drop.radius:
		other_drop.is_being_absorbed = true
		absorb_drop(other_drop)
	else:
		is_being_absorbed = true
		other_drop.absorb_drop(self)


func absorb_drop(other_drop: Raindrop) -> void:
	if not is_instance_valid(other_drop):
		return
	
	# Combine the masses of the raindrops
	var original_mass := mass
	var other_mass := other_drop.mass
	var combined_mass := original_mass + other_mass
	
	# Combine the stats of the raindrops
	weightStat = combine_stat(weightStat, other_drop.weightStat)
	friendlinessStat = combine_stat(friendlinessStat, other_drop.friendlinessStat)
	slipperinessStat = combine_stat(slipperinessStat, other_drop.slipperinessStat)
	
	# Preserving the visible area of both drops
	radius = sqrt(radius * radius + other_drop.radius * other_drop.radius)
	
	# Combines the movement of both drops
	linear_velocity = (linear_velocity * original_mass + other_drop.linear_velocity * other_mass) / combined_mass
	
	update_drop_size()
	
	start_sliding()
	
	if other_drop.isSelected:
		set_selected(true)
	
	raindropName = raindropName + " + " + other_drop.raindropName
	
	other_drop.queue_free()

func combine_stat(stat_a: int, stat_b: int) -> int:
	return max(stat_a, stat_b) + roundi(min(stat_a, stat_b) * 0.5)

func fade_in_drop() -> void:
	
	raindrop_sprite.modulate.a = 0.0
	
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(raindrop_sprite, "modulate:a", 1.0, 1.0)
	
	await tween.finished

func fade_out_drop() -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(raindrop_sprite, "modulate:a", 0, 1.0)
	
	await tween.finished
	remove_drop()

func remove_drop() -> void:
	queue_free()


func _on_area_2d_mouse_entered() -> void:
	raindrop_ui.show()


func _on_area_2d_mouse_exited() -> void:
	raindrop_ui.hide()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			raindropSelected.emit(self)
			set_selected(true)

func set_selected(value: bool) -> void:
	isSelected = value
	raindrop_sprite.set_instance_shader_parameter("selected", value)


func remove_selection_effect() -> void:
	set_selected(false)
