extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func fadeOut():
	animation_player.play("FadeOut")
	await animation_player.animation_finished


func fadeIn():
	animation_player.play("FadeIn")
	await animation_player.animation_finished
