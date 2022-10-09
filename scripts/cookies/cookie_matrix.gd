class_name CookieMatrix
extends Object
# Class for holding a 2D array of cookies
# Since this class is dealing with an array directly, it is fine for lines to be grey or "unsafe"

var internal: Array

var width: int
var height: int
# Loose cookie array for all cookies for use in looping through all cookies no matter what order
var loose_cookies: Array

func _init(new_width: int, new_height: int, cookie_types: Array) -> void:
	width = new_width
	height = new_height
	var no_of_types = cookie_types.size()
	for n in range(width):
		var cookie_column := CookieArray.new()
		for n2 in range(height):
			var cookie: Cookie = cookie_types[randi()%no_of_types].new()
			cookie.set_grid(n2,n)
			cookie.update_position()
			cookie_column.append(cookie)
			loose_cookies.append(cookie)
		internal.append(cookie_column)


func get_loose_cookies() -> Array:
	return loose_cookies


func get_cookie(v: Vector2) -> Cookie:
	return internal[v.x].get_cookie(v.y)


func set_cookie(v: Vector2, c: Cookie) -> void:
	internal[v.x].set_cookie(v.y, c)


func get_cookie_row(y: int) -> CookieArray:
	return internal[y]


func get_cookie_column(x: int) -> CookieArray:
	var result_array := CookieArray.new()
	for cookie_row in internal:
		result_array.append(cookie_row.get_cookie(x))
	return result_array


# Rotate a certain column in the cookie matrix
# go through each row array and rotate that at a position by distance
func rotate_matrix_column(column: int, distance: int) -> void:
	# Rotate a matrix row by a distance
	var stored_array := CookieArray.new()
	for i in range(width):
		stored_array.append(get_cookie(Vector2(i,column)))
	for i in range(width):
		var new_i := (i+distance)%8
		set_cookie(Vector2(i,column), stored_array.get_cookie(new_i))


# Easy, just rotate the list at cookie_start.x by distance
func rotate_matrix_row(row: int, distance: int) -> void:
	get_cookie_row(row).rotate(distance)


func update() -> void:
	for n in range(width):
		internal[n].update_array_row(n)
