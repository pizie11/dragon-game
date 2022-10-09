class_name Cookie
extends Sprite

onready var image := preload("res://icon.png")

var grid_pos := Vector2()
var shift_pos := Vector2()
var clone : Sprite


func _ready() -> void: 
	texture = image
	centered = false
	#setup our clone
	clone = Sprite.new()
	clone.texture = texture
	clone.centered = false


func update_position() -> void:
	position.x = (grid_pos.x * C.COOKIE_WIDTH) + shift_pos.x
	position.y = (grid_pos.y * C.COOKIE_HEIGHT) + shift_pos.y


# Create shadow clones 8*64 pixels away in x axis
func create_clones_x() -> void:
	create_single_clone(C.CLONE_EAST)
	create_single_clone(C.CLONE_WEST)


# Create shadow clones 8*64 pixels away in y axis
func create_clones_y() -> void:
	create_single_clone(C.CLONE_NORTH)
	create_single_clone(C.CLONE_SOUTH)


# Create empty clone sprite for visual purposes
func create_single_clone(v: Vector2) -> void:
	var new_clone = clone.duplicate()
	new_clone.position = v
	add_child(new_clone)


# Destroy all clone spritees
func destroy_clones() -> void:
	for child in get_children():
		child.queue_free()


# setters/getters for grid
func set_grid(x_val : int, y_val : int) -> void:
	grid_pos = Vector2(x_val, y_val)


func get_grid() -> Vector2:
	return grid_pos
	

func get_grid_swap() -> Vector2:
	return Vector2(grid_pos.y,grid_pos.x)


# set/get for shift
func set_shift(new: Vector2) -> void:
	shift_pos = new
	

func get_shift() -> Vector2:
	return shift_pos
