extends Control

@onready var endSprite = $TheEnd
@onready var playAgain_button = $PlayAgainButton
@onready var credits_button = $CreditsButton
@onready var finalScore = $FinalScore

func _ready() -> void:
	endSprite.modulate.a = 0.0
	finalScore.text = "%d" % GameData.final_score
	
	var tween := create_tween()
	tween.tween_property(
		endSprite,
		"modulate:a",
		1.0,
		1.0
	)

func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_file("res://new_main.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/scenes/credits/scrolling_credits.tscn")
