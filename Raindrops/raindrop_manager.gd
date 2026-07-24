extends Node2D

@export var raindrop_scene: PackedScene
@export var raindrop_ui_scene: PackedScene

@export var maximum_speed: int = 10

@export_range(0.0, 100000.0, 1.0) var spawn_length: float = 1000.0
@export var spawn_y: float = 0.0

@export_range(0, 10000, 1) var raindrop_count: int = 10
@export var spawn_on_ready: bool = true

var rng := RandomNumberGenerator.new()

var raindrop_spawn_data: Array[Dictionary] = []
var spawned_raindrops: Array[Node2D] = []

var selected_raindrop: Node2D
var race_started: bool = false

func _ready() -> void:
	rng.randomize()

	if spawn_on_ready:
		prepare_and_spawn_raindrops()


func determine_raindrop_spawnpoints(amount: int) -> void:
	raindrop_spawn_data.clear()

	#TODO: Hookup raindrop stats from DayData

	var half_length: float = spawn_length / 2.0

	for i in range(amount):
		var spawn_data := {
			"position": Vector2(
				rng.randf_range(-half_length, half_length),
				spawn_y
			),
			"speed": rng.randf_range(1.0, maximum_speed),
			"angle": rng.randf_range(-20.0, 20.0),
			"weight": rng.randi_range(1, 10),
			"friendliness": rng.randi_range(1, 10),
			"slipperiness": rng.randi_range(1, 10)
		}

		raindrop_spawn_data.append(spawn_data)


func spawn_raindrops() -> void:
	#spawned_raindrops.clear()
	
	race_started = false

	for spawn_data in raindrop_spawn_data:
		var raindrop_instance := raindrop_scene.instantiate()

		raindrop_instance.position = spawn_data["position"]
		raindrop_instance.setup_race_data(spawn_data["speed"], spawn_data["angle"])

		add_child(raindrop_instance)
		
		raindrop_instance.prepare_for_race()

		#create_raindrop_ui(raindrop_instance, spawn_data)

		spawned_raindrops.append(raindrop_instance)

func begin_race() -> void:
	if race_started:
		return
		
	race_started = true
	
	for raindrop in spawned_raindrops:
		if is_instance_valid(raindrop):
			raindrop.begin_racing()

func clear_spawned_raindrops() -> void:
	for raindrop in spawned_raindrops:
		if is_instance_valid(raindrop):
			raindrop.queue_free()
		
	spawned_raindrops.clear()
	selected_raindrop = null


func create_raindrop_ui(raindrop: Node2D, spawn_data: Dictionary) -> void:
	if raindrop_ui_scene == null:
		return

	#var ui_instance := raindrop_ui_scene.instantiate()

	#raindrop.add_child(ui_instance)

	#ui_instance.setup(raindrop, spawn_data)
	#ui_instance.choose_requested.connect(_on_raindrop_choose_requested)


func prepare_and_spawn_raindrops() -> void:
	determine_raindrop_spawnpoints(raindrop_count)
	spawn_raindrops()


func select_raindrop(raindrop: Node2D) -> void:
	if selected_raindrop != null:
		selected_raindrop.isSelected = false

	selected_raindrop = raindrop
	selected_raindrop.isSelected = true

	for spawned_raindrop in spawned_raindrops:
		if spawned_raindrop.has_method("update_selection_display"):
			spawned_raindrop.update_selection_display()


func _on_raindrop_choose_requested(raindrop: Node2D) -> void:
	select_raindrop(raindrop)


func _on_spawn_raindrops_button_pressed() -> void:
	prepare_and_spawn_raindrops()


func _on_start_race_button_pressed() -> void:
	begin_race()
