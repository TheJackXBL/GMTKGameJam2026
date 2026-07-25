extends StaticBody2D
class_name WindowObstacle

@export var data : ObstacleData

@onready var sprite := $Sprite2D
@onready var collision := $CollisionPolygon2D

func _ready():
	sprite.texture = data.texture
	collision.polygon = data.collision
