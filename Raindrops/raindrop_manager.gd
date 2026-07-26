extends Node2D

signal raindropSelected

@export var raindrop_scenes: Array[PackedScene]
@export var raindrop_ui_scene: PackedScene
@onready var streak_container: Node2D = $StreakContainer


@export var maximum_speed: int = 10

@export var min_spawn_x: float = 0.0
@export var max_spawn_x: float = 0.0
@export var spawn_y: float = 0.0

@export_range(0, 10000, 1) var raindrop_count: int = 10
@export var spawn_on_ready: bool = true

var rng := RandomNumberGenerator.new()

var raindrop_spawn_data: Array[Dictionary] = []
var spawned_raindrops: Array[Node2D] = []

var raindrop_names: Array[String] = [
	"Jonathan",
	"Dewey",
	"Walter",
	"Todd",
	"Bloop",
	"Percy",
	"Pip",
	"Droop",
	"Big Dewd",
	"Drippy",
	"Mark",
	"Timmy",
	"Benedict",
	"Fred", 
	"Darla",
	"Polly",
	"Annie",
	"Jack",
	"Bosco",
	"Aro",
	"Livi",
	"Matt",
	"Maaacks",
	"Nathan",
	"Reyn",
	"Bird",
	"Damien",
	"Daisy",
	"Callum",
	"Beatrix",
	"Dan"
]

var current_names: Array[String]


var selected_raindrop: Node2D
var race_started: bool = false

func _ready() -> void:
	rng.randomize()

	if spawn_on_ready:
		prepare_and_spawn_raindrops()

func generate_stats() -> Array[int]:
	var minimum_stat: int = 2
	var point_pool: int = 10
	var remaining_points: int = point_pool - (minimum_stat * 3)
	
	var possible_cuts: Array[int] = []
	
	for i in range(remaining_points + 2):
		possible_cuts.append(i)
	
	possible_cuts.shuffle()
	
	var cuts: Array[int] = [
		possible_cuts[0],
		possible_cuts[1]
	]
	
	cuts.sort()
	
	return [
		minimum_stat + cuts[0],
		minimum_stat + cuts[1] - cuts[0] - 1,
		minimum_stat + remaining_points - cuts[1] + 1
	]


func determine_raindrop_spawnpoints(amount: int) -> void:
	raindrop_spawn_data.clear()

	#TODO: Hookup raindrop stats from DayData
	
	var section_width: float = (max_spawn_x - min_spawn_x) / amount
	
	current_names = raindrop_names.duplicate()
	
	for i in range(amount):
		
		var section_start: float = min_spawn_x + (i * section_width)
		var section_end: float = section_start + section_width
		
		var random_name = current_names.pick_random()
		current_names.erase(random_name)
		
		var generated_stats: Array[int] = generate_stats()
		
		var spawn_data := {
			"name": random_name,
			"position": Vector2(
				rng.randf_range(section_start, section_end),
				spawn_y
			),
			"speed": rng.randf_range(1.0, maximum_speed), 
			"angle": rng.randf_range(-20.0, 20.0),
			"weight": generated_stats[0], 
			"friendliness": generated_stats[1],
			"slipperiness": generated_stats[2]
		}

		raindrop_spawn_data.append(spawn_data)


func spawn_raindrops() -> void:
	#spawned_raindrops.clear()
	
	race_started = false

	for spawn_data in raindrop_spawn_data:
		
		var raindrop_type := raindrop_scenes[randi_range(0, raindrop_scenes.size() - 1)]
		
		var raindrop_instance := raindrop_type.instantiate()

		raindrop_instance.position = spawn_data["position"]
		
		add_child(raindrop_instance)
		
		raindrop_instance.setup_race_data(
			spawn_data["name"],
			spawn_data["speed"], 
			spawn_data["angle"], 
			spawn_data["weight"], 
			spawn_data["friendliness"], 
			spawn_data["slipperiness"]
		)
		
		raindrop_instance.prepare_for_race() #Freezes raindrops in place

		#create_raindrop_ui(raindrop_instance, spawn_data)

		spawned_raindrops.append(raindrop_instance)
		
		raindrop_instance.raindropSelected.connect(select_raindrop)

func begin_race() -> void:
	if race_started:
		return
		
	race_started = true
	
	for raindrop in spawned_raindrops:
		if is_instance_valid(raindrop):
			raindrop.begin_racing()

func fade_remaining_raindrops() -> void:
	for raindrop in spawned_raindrops:
		if is_instance_valid(raindrop):
			raindrop.fade_out_drop()

func clear_spawned_raindrops() -> void:
	for raindrop in spawned_raindrops:
		if is_instance_valid(raindrop):
			raindrop.queue_free()
		
	spawned_raindrops.clear()
	selected_raindrop = null


func prepare_and_spawn_raindrops() -> void:
	determine_raindrop_spawnpoints(raindrop_count)
	spawn_raindrops()


func select_raindrop(raindrop: Node2D) -> void:
	if selected_raindrop != null:
		selected_raindrop.isSelected = false
		selected_raindrop.remove_selection_effect()

	selected_raindrop = raindrop
	selected_raindrop.isSelected = true

	print("Selected: ", raindrop.raindropName)
	
	raindropSelected.emit()


func _on_spawn_raindrops_button_pressed() -> void:
	prepare_and_spawn_raindrops()


func start_race() -> void:
	begin_race()

func clear_streaks() -> void:
	for child in streak_container.get_children():
		child.queue_free()
