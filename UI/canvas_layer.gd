extends CanvasLayer

signal countdown_finished

@onready var animation_player = $AnimationPlayer

@export var number_duration: float = 1.0
@export var go_duration: float = 1.0

@onready var label_3: Label = $CountdownContainer/Label3
@onready var label_2: Label = $CountdownContainer/Label2
@onready var label_1: Label = $CountdownContainer/Label1
@onready var go_label: Label = $CountdownContainer/GoLabel

@onready var score_label: Label = $ScoreLabel

@onready var start_race_button: TextureButton = $"Go Button Container/Start Race Button"

@export var tutorial_overlay: Array[TextureRect]
@export var current_overlay := 0


var displayed_score: int = 0

var countdown_running: bool = false

func _ready() -> void:
	hide_all_labels()

func showGoButton() -> void:
	start_race_button.show()

func hideGoButton() -> void:
	start_race_button.hide()

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
	
	hideGoButton()
	start_countdown()


func _on_race_manager_score_changed(new_score: Variant) -> void:
	
	update_score(new_score)

func update_score(new_score: int) -> void:
	score_label.pivot_offset = score_label.size / 2.0
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	tween.tween_method(_set_displayed_score, displayed_score, new_score, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.chain().tween_property(score_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
func _set_displayed_score(value: int) -> void:
	displayed_score = value
	score_label.text = str(displayed_score)


func _on_raindrop_manager_raindrop_selected() -> void:
	
	if start_race_button.visible == false:
		showGoButton()
	

func show_next_overlay() -> void:
	
	tutorial_overlay[current_overlay - 1].hide()
	
	if current_overlay + 1 > tutorial_overlay.size():
		return
	
	tutorial_overlay[current_overlay].show()
	
	current_overlay += 1
	
