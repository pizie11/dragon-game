class_name CookieClass
extends Sprite

onready var image = preload("res://icon.png")

var gridX = 0
var gridY = 0
var offsetX = 0
var offsetY = 0

func update_position():
	position.x = (gridX * 64) + offsetX
	position.y = (gridY * 64) + offsetY

func _ready() -> void:
	texture = image
	centered = false
