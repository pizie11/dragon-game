class_name CookieClass
extends Sprite

onready var image = preload("res://icon.png")
var gridX = 0
var gridY = 0

func update_position():
	position.x = (gridX * 64) + 4
	position.y = (gridY * 64) + 4

func _ready() -> void:
	texture = image
	centered = false
