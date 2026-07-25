class_name Droplet
extends Area2D

@export var radius: float = 2.0
@export var droplet_sprites: Array[Texture2D]

@onready var sprite: Sprite2D = $Sprite2D

var is_being_absorbed: bool = false


func _ready() -> void:
	choose_random_sprite()
	body_entered.connect(_on_body_entered)

func choose_random_sprite() -> void:
	if droplet_sprites.is_empty():
		push_warning("No droplet sprites have been assigned.")
		return

	sprite.texture = droplet_sprites.pick_random()


func _on_body_entered(body: Node2D) -> void:
	if is_being_absorbed:
		return

	if body is not Raindrop:
		return

	is_being_absorbed = true

	var raindrop := body as Raindrop
	raindrop.absorb_droplet(self)
