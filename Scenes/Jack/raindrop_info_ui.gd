extends Control

signal choose_requested(raindrop: Node2D)

@export var filled_colour := Color("#ffca0a")
@export var empty_colour := Color("#444ed0")
@export var segment_count: int = 10

@onready var name_label: Label = %NameLabel
@onready var speed_value: Label = %SpeedValue

@onready var weight_value: Label = %WeightValue
@onready var friendliness_value: Label = %FriendlinessValue
@onready var slipperiness_value: Label = %SlipperinessValue

@onready var weight_bar: TextureRect = %WeightBar
@onready var slipperiness_bar: TextureRect = %SlipperinessBar
@onready var friendliness_bar: TextureRect = %FriendlinessBar

@export var bar_textures: Array[Texture2D]


@onready var choose_button: Button = %ChooseButton

var raindrop: Node2D


func _ready() -> void:
	pass
	#dropdown_button.pressed.connect(_on_dropdown_button_pressed)
	#choose_button.pressed.connect(_on_choose_button_pressed)


func update_display(drop_name: String, speed: int, angle: float, weight: int, friendliness: int, slipperiness: int) -> void:

	name_label.text = "Name: " + str(drop_name)
	speed_value.text = str(speed) + "mm/s"
	
	weight_value.text = str(weight)
	friendliness_value.text = str(friendliness)
	slipperiness_value.text = str(slipperiness)
	
	#TODO - Adjust bars to match stats

	update_stat_bar(weight_bar, weight)
	update_stat_bar(friendliness_bar, friendliness)
	update_stat_bar(slipperiness_bar, slipperiness)


func update_stat_bar(bar: TextureRect, value: int) -> void:
	
	bar.texture = bar_textures[value-1]


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


func _on_raindrop_raindrop_stats_generated(drop_name: String, speed: int, angle: float, weight: int, friendliness: int, slipperiness: int) -> void:
	update_display(drop_name, speed, angle, weight, friendliness, slipperiness)
