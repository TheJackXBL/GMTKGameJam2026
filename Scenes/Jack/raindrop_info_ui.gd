extends Control

signal choose_requested(raindrop: Node2D)

@export var filled_colour := Color("#ffca0a")
@export var empty_colour := Color("#444ed0")
@export var segment_count: int = 10

@onready var speed_value: Label = %SpeedValue

@onready var weight_value: Label = %WeightValue
@onready var friendliness_value: Label = %FriendlinessValue
@onready var slipperiness_value: Label = %SlipperinessValue

@onready var choose_button: Button = %ChooseButton

var raindrop: Node2D


func _ready() -> void:
	pass
	#dropdown_button.pressed.connect(_on_dropdown_button_pressed)
	#choose_button.pressed.connect(_on_choose_button_pressed)


func update_display(speed: int, angle: float, weight: int, friendliness: int, slipperiness: int) -> void:

	speed_value.text = str(speed) + "mm/s"
	
	weight_value.text = str(weight)
	friendliness_value.text = str(friendliness)
	slipperiness_value.text = str(slipperiness)
	
	#TODO - Adjust bars to match stats

	#create_stat_bar(weight_bar, weight)
	#create_stat_bar(friendliness_bar, friendliness)
	#create_stat_bar(slipperiness_bar, slipperiness)


func create_stat_bar(container: HBoxContainer, value: int) -> void:
	for child in container.get_children():
		child.queue_free()

	var clamped_value := clampi(value, 0, segment_count)

	for i in range(segment_count):
		var segment := Panel.new()

		segment.custom_minimum_size = Vector2(26.0, 42.0)
		segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var style_box := StyleBoxFlat.new()

		if i < clamped_value:
			style_box.bg_color = filled_colour
		else:
			style_box.bg_color = empty_colour

		style_box.border_width_left = 2
		style_box.border_width_top = 2
		style_box.border_width_right = 2
		style_box.border_width_bottom = 2

		style_box.border_color = Color.BLACK

		segment.add_theme_stylebox_override("panel", style_box)
		container.add_child(segment)


#func _on_dropdown_button_pressed() -> void:
	#dropdown_panel.visible = not dropdown_panel.visible
#
	#if dropdown_panel.visible:
		#dropdown_button.text = dropdown_button.text.replace("▼", "▲")
	#else:
		#dropdown_button.text = dropdown_button.text.replace("▲", "▼")


#func _on_choose_button_pressed() -> void:
	#if raindrop == null:
		#return
#
	#choose_requested.emit(raindrop)
	#dropdown_panel.visible = false
	#dropdown_button.text = dropdown_button.text.replace("▲", "▼")


func _on_raindrop_raindrop_stats_generated(speed: int, angle: float, weight: int, friendliness: int, slipperiness: int) -> void:
	update_display(speed, angle, weight, friendliness, slipperiness)
