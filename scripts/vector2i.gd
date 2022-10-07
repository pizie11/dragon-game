class_name Vector2I
extends Object
# Vector2 but with integers, does not have every feature of a normal Vector2, used only for grid stuff

var x : int
var y : int

func _init(new_x := 0, new_y := 0) -> void:
	x = new_x
	y = new_y
