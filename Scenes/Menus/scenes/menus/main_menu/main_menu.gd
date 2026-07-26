extends MainMenu


func stop_music() -> void:
	background_music_player.stop()


func _on_game_started() -> void:
	stop_music()
