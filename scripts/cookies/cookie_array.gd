class_name CookieArray
extends Object
# Since this class is dealing with an array directly, it is fine for lines to be grey or "unsafe"

var internal : Array

func append(c : Cookie)-> void:
	internal.append(c)


func get_cookie(i : int) -> Cookie:
	var c = internal[i]
	return c


func set_cookie(i: int, c:Cookie) -> void:
	internal[i] = c


func set_global_shift(v: Vector2, keep_x=false, keep_y=false)->void:
	for cookie in internal:
		var new_shift: Vector2 = cookie.get_shift()
		if !keep_x:
			new_shift.x = v.x
		if !keep_y:
			new_shift.y = v.y
		cookie.set_shift(new_shift)
		cookie.update_position()


# Rotate an array to the right by n
func rotate(n: int) -> void:
	var first_part := internal.slice(n, internal.size()-1, 1, true)
	var second_part := internal.slice(0,n-1, 1, true)
	internal = first_part + second_part 


# updates the grid, shift, and position of every cookie in the array
# row is the row all the cookies in this array should be set to when displayed
func update_array(row: int, grid_height: int) -> void:
	for n in range(grid_height):
		internal[n].set_grid(row,n)
		internal[n].set_shift(Vector2(0,0))
		internal[n].update_position()


func make_x_clones() -> void:
	for c in internal:
		c.create_clones_x()


func make_y_clones() -> void:
	for c in internal:
		c.create_clones_y()


func delete_clones() -> void:
	for c in internal:
		c.destroy_clones()
