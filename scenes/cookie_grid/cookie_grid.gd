extends Node2D

# State vars
enum states {CLICK_STATE, DRAG_STATE, SCORE_STATE}
var current_state = states.CLICK_STATE

onready var timer := ($Timer as Timer)

var cookie_types := [Cookie, CookieRed, CookieGreen]

const GRID_WIDTH = 8
const GRID_HEIGHT = 8

const COOKIE_SIZE_X = 64
const COOKIE_SIZE_Y = 64

# mouse start and end positions of drag
var mouse_position_start := Vector2(-1, -1)
var mouse_position_end := Vector2(-1, -1)

# Cookie grid matrix
var cookie_matrix := []

# Grid boundaries
var north: float
var south: float
var east: float
var west: float

# vars for click state
var start_cookie := Vector2()
var end_cookie := Vector2()

# vars for drag state
var move_x: bool
var move_y: bool
var mouse_delta := Vector2()
var cookie_listY := []
var cookie_listX := []

# Boolean flags
var have_click := false
var in_grace := false

func _ready() -> void:
	for n in range(GRID_WIDTH):
		var cookie_column := []
		for n2 in range(GRID_HEIGHT):
			var cookie: Cookie = cookie_types[randi()%3].new()
			cookie.set_grid(n,n2)
			cookie.update_position()
			cookie_column.append(cookie)
			add_child(cookie)
		cookie_matrix.append(cookie_column)
	print(cookie_matrix[7][7])
	north = global_position.y
	south = global_position.y + COOKIE_SIZE_Y * GRID_HEIGHT
	east = global_position.x + COOKIE_SIZE_X * GRID_WIDTH
	west = global_position.x

func _process(_delta: float) -> void:
	match current_state:
		states.CLICK_STATE: # CLICK-> DRAG
			_click_to_drag()
		states.DRAG_STATE:
			_do_drag()
			_drag_to_score()
		states.SCORE_STATE:
			print("SCORE->CLICK")
			current_state = states.CLICK_STATE
			have_click = false
			
### STATE FUNCTIONS
# Click state to drag state transition
func _click_to_drag() -> void:
	if (have_click and is_in_box(mouse_position_start, north,south,east, west)):
		print("CLICK->DRAG")
		var found_cookie := get_grid_of_position(mouse_position_start)
		print(found_cookie)
		# DO NOT ALTER, TO FIX X/Y WIERDNESS
		start_cookie.x = found_cookie.y
		start_cookie.y = found_cookie.x
		cookie_listY = cookie_matrix[start_cookie.y]
		for cookie_column in cookie_matrix:
			cookie_listX.append(cookie_column[start_cookie.x])
		mouse_position_end = Vector2(-1,-1)
		mouse_delta = Vector2()
		current_state = states.DRAG_STATE

# Doing dragging update in drag state
func _do_drag() -> void:
	#handling cookie movement in drag state
	move_x = false
	move_y = false
	if abs(mouse_delta.y) > abs(mouse_delta.x):
		move_y = true
	else:
		move_x = true
	for cookie in cookie_listY:
		var new_shift: Vector2 = cookie.get_shift()
		if move_y:
			new_shift.x = 0
			new_shift.y = mouse_delta.y
		else:
			# X position stays the same!
			new_shift.y = 0
		cookie.set_shift(new_shift)
		cookie.update_position()
	for cookie in cookie_listX:
		var new_shift: Vector2 = cookie.get_shift()
		if move_x:
			new_shift.x = mouse_delta.x
			new_shift.y = 0
		else:
			new_shift.x = 0
			# Y position stays the same!
		cookie.set_shift(new_shift)
		cookie.update_position()

# Drag state to scoring state
func _drag_to_score() -> void:
	if have_click and mouse_delta.length() > 0 : #DRAG-> SCORE
		print("DRAG->SCORE")
		var found_cookie := get_grid_of_position(mouse_position_end)
		end_cookie = Vector2(found_cookie.y,found_cookie.x)
		var distance: Vector2 = end_cookie - start_cookie
		# move all cookies 
		if move_y and distance.x != 0: # Easy, just rotate the list at cookie_start.y by distance
			cookie_matrix[start_cookie.y] = rotate_array(cookie_matrix[start_cookie.y], -distance.x)
		if move_x: #Harder, go through each column list and rotate that at a position cookie_start.x by distance
			rotate_matrix_row(start_cookie.x, -distance.y)
		print("moving ",-distance, " spots")	
		# Do redundancy check on the whole grid matrix HERE
		# mostly for the cookie grid var
		update_matrix()
		# Reset certain vars
		mouse_position_start = Vector2()
		cookie_listX = []
		cookie_listY = []
		have_click = false
		in_grace = true
		current_state = states.SCORE_STATE
		timer.start()
### OTHER/HELPER FUNCTIONS
# Handle Mouse input
func _input(event: InputEvent) -> void:
	have_click = false
	if event is InputEventMouseButton and not in_grace:
		if current_state == states.CLICK_STATE:
			mouse_position_start = event.global_position
			have_click = true
		elif current_state == states.DRAG_STATE:
			mouse_position_end = event.global_position
			have_click = true
	elif event is InputEventMouseMotion:
		if current_state == states.DRAG_STATE:
			mouse_delta += event.relative
			return

# returns whether or not a click is within a north/south/east/west box! (COULD GO TO LIBRARY)
func is_in_box(pos: Vector2, n: float, s: float, e: float, w: float) -> bool:
	return pos.x > w and pos.x < e and pos.y > n and pos.y < s

# returns the grid position of a position
func get_grid_of_position(pos: Vector2) -> Vector2:
	var x_val := floor((pos.x - global_position.x) / COOKIE_SIZE_X)
	var y_val := floor((pos.y - global_position.y) / COOKIE_SIZE_Y)
	return Vector2(x_val, y_val)

# Rotate an array to the right by n (COULD GO TO LIBRARY
func rotate_array(arr: Array, n: int) -> Array:
	return arr.slice(n, arr.size()-1, 1) + arr.slice(0,n-1, 1)

# Update the variables of every cookie in the matrix
func update_matrix() -> void:
	for n in range(GRID_WIDTH):
		for n2 in range(GRID_HEIGHT):
			cookie_matrix[n][n2].set_grid(n,n2)
			cookie_matrix[n][n2].set_shift(Vector2(0,0))
			cookie_matrix[n][n2].update_position()

# Rotate a certain row in the cookie matrix
func rotate_matrix_row(row: int, distance: int) -> void:
	#Rotate a matrix row by a distance
	var stored_row := Array()
	for i in range(GRID_HEIGHT):
		stored_row.append(cookie_matrix[i][row])
	for i in range(GRID_HEIGHT):
		var new_i := (i+distance)%8
		cookie_matrix[i][row] = stored_row[new_i]
	#print(stored_row)

# Timer signal function
func exit_grace() -> void:
	in_grace = false
