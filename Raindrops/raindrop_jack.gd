class_name Raindrop
extends RigidBody2D

@onready var streak_container: Node2D = get_parent().get_node("StreakContainer")
@onready var drop_sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

#Drop size
@export var radius := 3.0
@export var starting_radius := 3.0

#Movement
@export var gravity_force := 100.0 # The downwards force being applied to the raindrop
@export var drag_strength := 1.8 # The resisting force to prevent the raindrop from accelerating too quickly, increase to slow acceleration
@export var maximum_speed := 400.0 # Hard cap on speed so we can incorporate it into stats

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

var streak: Line2D
var last_streak_position: Vector2

var is_sliding := false
var is_being_absorbed := false # When raindrops merge, prevents code from getting angry
var time_below_minimum_speed := 0.0 # If the raindrop is going too slow for too long, it attempts to stick to the glass

var adhesion_multiplier := 1.0 # Slipperyness stat, better slippy stats means lower multiplier

var original_sprite_scale: Vector2 # Starting size of sprite

var movement_noise := FastNoiseLite.new() # Found cool noise generator!
var noise_offset := 0.0 # Keeps noise varied



func _ready() -> void:
	
	body_entered.connect(_on_body_entered)
	
	original_sprite_scale = drop_sprite.scale
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


func _physics_process(delta: float) -> void:
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
	if not is_sliding:
		return
	
	noise_offset += state.step * direction_change_speed # step is the Rigidbody's version of delta
	
	var size_factor := clampf(radius / starting_radius, 0.4, 2.5) # bigger raindrops move faster by a significant factor, buffs merged raindrops
	var sideways_direction := movement_noise.get_noise_1d(noise_offset) # -1 is left, 1 is right
	
	# Pulls the raindrop down the window
	var downward_force := Vector2.DOWN * gravity_force * mass * (size_factor / 1.5)
	
	# Makes the drop gradually wander from side to side for randomness
	var horizontal_force := Vector2.RIGHT * sideways_direction * sideways_force * mass
	
	#Applying drag prevents the drop from accelerating forever, applies in the opposite direction of travel
	var drag_force := -state.linear_velocity * drag_strength * mass
	
	#Applies total of forces to raindrop
	state.apply_central_force(downward_force + horizontal_force + drag_force)
	
	# Hard caps raindrops just in case
	if state.linear_velocity.length() > maximum_speed:
		state.linear_velocity = state.linear_velocity.normalized() * maximum_speed


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

	streak.modulate.a = 0.2
	
	#Streak shader
	var shader := load("res://Scenes/Car/waterStreak.gdshader") as Shader
	streak.material = ShaderMaterial.new()
	streak.material.shader = shader
	
	streak_container.add_child(streak)

# Made adding streak point into function to keep things simple
func add_streak_point() -> void: 
	streak.add_point(streak.to_local(global_position))
	last_streak_position = global_position

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
	var speed_ratio := clampf(linear_velocity.length() / maximum_speed, 0.0, 1.0) # 0 = stationary, 1 = max speed
	
	# Stretching faster drops downwards
	var stretch_amount := speed_ratio * maximum_stretch
	
	var stretch_scale := Vector2(1.0 - stretch_amount * 0.35, 1.0 + stretch_amount) # Slightly narrower, but way more stretched vertically
	
	var target_scale := original_sprite_scale * size_scale * stretch_scale
	var interpolation := 1.0 - exp(-stretch_speed * delta)
	
	drop_sprite.scale = drop_sprite.scale.lerp(target_scale,interpolation)

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
	
	# Preserving the visible area of both drops
	radius = sqrt(radius * radius + other_drop.radius * other_drop.radius)
	
	# Combines the movement of both drops
	linear_velocity = (linear_velocity * original_mass + other_drop.linear_velocity * other_mass) / combined_mass
	
	update_drop_size()
	
	start_sliding()

	other_drop.queue_free() #TODO - Add raindrop selection and have it so if your selection merges, the resulting raindrop is the new selection


func remove_drop() -> void:
	queue_free()
