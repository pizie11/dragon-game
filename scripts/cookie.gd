class_name CookieClass
extends Sprite

onready var image := preload("res://icon.png")

var grid_pos := Vector2()
var shift_pos := Vector2()

func _ready() -> void: 
	texture = image
	centered = false

func update_position() -> void:
	position.x = (grid_pos.x * 64) + shift_pos.x
	position.y = (grid_pos.y * 64) + shift_pos.y

func set_grid(x_val : int, y_val : int) -> void:
	grid_pos = Vector2(x_val, y_val)

func get_grid() -> Vector2:
	return grid_pos

func set_shift(new: Vector2) -> void:
	shift_pos = new
	
func get_shift() -> Vector2:
	return shift_pos
