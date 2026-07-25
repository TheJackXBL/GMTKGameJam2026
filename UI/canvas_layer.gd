extends CanvasLayer

signal countdown_finished

@onready var animation_player = $AnimationPlayer

@export var number_duration: float = 1.0
@export var go_duration: float = 1.0

@onready var label_3: Label = $CountdownContainer/Label3
@onready var label_2: Label = $CountdownContainer/Label2
@onready var label_1: Label = $CountdownContainer/Label1
@onready var go_label: Label = $CountdownContainer/GoLabel

var countdown_running: bool = false

func _ready() -> void:
	hide_all_labels()

func start_countdown() -> void:
	if countdown_running:
		return

	countdown_running = true
	hide_all_labels()

	await show_label_for_time(label_3, number_duration)
	await show_label_for_time(label_2, number_duration)
	await show_label_for_time(label_1, number_duration)

	go_label.show()
	countdown_finished.emit()

	await get_tree().create_timer(go_duration).timeout

	go_label.hide()
	countdown_running = false


func show_label_for_time(label: Label, duration: float) -> void:
	label.show()
	await get_tree().create_timer(duration).timeout
	label.hide()


func hide_all_labels() -> void:
	label_3.hide()
	label_2.hide()
	label_1.hide()
	go_label.hide()


func fadeOut():
	animation_player.play("FadeOut")
	await animation_player.animation_finished


func fadeIn():
	animation_player.play("FadeIn")
	await animation_player.animation_finished


func _on_race_manager_start_countdown() -> void:
	start_countdown()
