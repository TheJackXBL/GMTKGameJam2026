extends Control

@onready var endSprite = $TheEnd
@onready var playAgain_button = $PlayAgainButton
@onready var credits_button = $CreditsButton
@onready var finalScore = $FinalScore
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	endSprite.modulate.a = 0.0
	
	playAgain_button.hide()
	playAgain_button.modulate.a = 0.0
	
	fadeOut()
	
	finalScore.text = "%d" % GameData.final_score
	
	await get_tree().create_timer(3).timeout
	
	play_ending_dialogue()
	

func show_the_end() -> void:
	
	var tween := create_tween()
	tween.tween_property(
		endSprite,
		"modulate:a",
		1.0,
		1.0
	)
	
	playAgain_button.show()
	var tween2 := create_tween()
	tween2.tween_property(
		playAgain_button,
		"modulate:a",
		1.0,
		1.0
	)

func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_file("res://new_main.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/scenes/credits/scrolling_credits.tscn")

func play_ending_dialogue() -> void:
	
	var dialogue_path = "res://Dialogue/Dialog_Day4.dialogue"
	
	var dialogue = load(dialogue_path)
	
	DialogueManager.show_dialogue_balloon(dialogue, "day_start",[{ "game": self }])

func fadeOut():
	animation_player.play("FadeOut")
	await animation_player.animation_finished


func fadeIn():
	animation_player.play("FadeIn")
	await animation_player.animation_finished
