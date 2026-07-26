extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var fade_duration := 0.2


func play_smack():
	#Start invisible
	modulate.a = 0.0
	show()
	
	#Fade in
	var tween := create_tween()
	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		fade_duration
	)
	
	await tween.finished
	
	
	#Play smack animation
	sprite.play("smack")
	
	print("Playing smack animation")
	
	await sprite.animation_finished
	
	print("Smack animation finished")
	
	
	#Fade out
	tween = create_tween()
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		fade_duration
	)
	
	await tween.finished
	
	queue_free()
