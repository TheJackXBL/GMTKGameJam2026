extends Label

func display_position(placement: int) -> void:
	text = get_placement(placement)
	
	modulate.a = 1.0
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(
		self,
		"position:y",
		position.y - 70.0,
		1.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		1.0
	).set_delay(1.5)
	
	tween.chain().tween_callback(queue_free)


func get_placement(number: int) -> String:
	match number:
		1:
			return "1st"
		2:
			return "2nd"
		3:
			return "3rd"
		_:
			return str(number) + "th"
