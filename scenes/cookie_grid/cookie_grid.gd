extends Node2D

# State vars
enum states {CLICK_STATE, DRAG_STATE, SCORE_STATE}
var current_state = states.CLICK_STATE

onready var timer := ($Timer as Timer)

var cookie_types := [Cookie, CookieRed, CookieGreen]

# mouse start and end positions of drag
var mouse_position_start := Vector2(-1, -1)
var mouse_position_end := Vector2(-1, -1)

# Cookie grid matrix
var cookie_columns := []

# Grid boundaries
var north : float
var south : float
var east : float
var west : float

# vars for click state
var start_cookie := Vector2()
var end_cookie := Vector2()

# vars for drag state
var mouse_delta := Vector2()
var cookie_listY := []
var cookie_listX := []

# Boolean flags
var have_click := false
var in_grace := false

func _ready() -> void:
	for n in range(8):
		var cookie_row := []
		for n2 in range(8):
			var cookie = cookie_types[randi()%3].new()
			cookie.set_grid(n,n2)
			cookie.update_position()
			cookie_row.append(cookie)
			add_child(cookie)
		cookie_columns.append(cookie_row)
	print(cookie_columns[7][7])
	north = global_position.y
	south = global_position.y + 64 * 8
	east = global_position.x + 64 * 8
	west = global_position.x
	var testlist = [1,2,3,4]
	var newlist = rotate_array(testlist,1)
	print(newlist)

func _process(delta: float) -> void:
	match current_state:
		states.CLICK_STATE: # CLICK-> DRAG
			if (have_click and is_in_box(mouse_position_start, north,south,east, west)):
				print("CLICK->DRAG")
				var found_cookie = get_grid_of_position(mouse_position_start)
				print(found_cookie)
				# DO NOT ALTER, TO FIX X/Y WIERDNESS
				start_cookie.x = found_cookie.y
				start_cookie.y = found_cookie.x
				cookie_listY = cookie_columns[start_cookie.y]
				for cookie_column in cookie_columns:
					cookie_listX.append(cookie_column[start_cookie.x])
				mouse_position_end = Vector2(-1,-1)
				mouse_delta = Vector2()
				current_state = states.DRAG_STATE
				return
		states.DRAG_STATE:
			#handling cookie movement in drag state
			var move_X = false
			var move_Y = false
			if abs(mouse_delta.y) > abs(mouse_delta.x):
				move_Y = true
			else:
				move_X = true
			for cookie in cookie_listY:
				var new_shift :Vector2= cookie.get_shift()
				if move_Y:
					new_shift.x = 0
					new_shift.y = mouse_delta.y
				else:
					# X position stays the same!
					new_shift.y = 0
				cookie.set_shift(new_shift)
				cookie.update_position()
			for cookie in cookie_listX:
				var new_shift:Vector2= cookie.get_shift()
				if move_X:
					new_shift.x = mouse_delta.x
					new_shift.y = 0
				else:
					new_shift.x = 0
					# Y position stays the same!
				cookie.set_shift(new_shift)
				cookie.update_position()
			if have_click and mouse_delta.length() > 0 : #DRAG-> SCORE
				print("DRAG->SCORE")
				# Make a new list just for affected cookies
				var affected_cookies : Array
				if move_X:
					affected_cookies = cookie_listY
				elif move_Y:
					affected_cookies = cookie_listX
				var found_cookie := get_grid_of_position(mouse_position_end)
				end_cookie = Vector2(found_cookie.y,found_cookie.x)
				var distance :Vector2= end_cookie - start_cookie
				
				# move all cookies 
				if move_Y and distance.x != 0: # Easy, just rotate the list at cookie_start.y by distance
					cookie_columns[start_cookie.y] = rotate_array(cookie_columns[start_cookie.y], -distance.x)
				if move_X: #Harder, go through each column list and rotate that at a position cookie_start.x by distance
					rotate_grid_row(start_cookie.x, -distance.y)
				print("moving ",-distance, " spots")	
				# Do redundancy check on the whole grid matrix HERE
				# mostly for the cookie grid var
				update_grid()
				# Reset certain vars
				mouse_position_start = Vector2()
				cookie_listX = []
				cookie_listY = []
				have_click = false
				in_grace = true
				current_state = states.SCORE_STATE
				timer.start()
		states.SCORE_STATE:
			print("SCORE->CLICK")
			current_state = states.CLICK_STATE
			have_click = false
			

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

# returns whether or not a click is within a north/south/east/west box!
func is_in_box(pos:Vector2, north:float, south:float, east:float, west:float) -> bool:
	return pos.x > west and pos.x < east and pos.y > north and pos.y < south

# returns the grid position of a position
func get_grid_of_position(pos:Vector2)->Vector2:
	var x_val := floor((pos.x - global_position.x) / 64)
	var y_val := floor((pos.y - global_position.y) / 64)
	return Vector2(x_val, y_val)

func rotate_array(arr:Array, n:int)-> Array:
	return arr.slice(n, arr.size()-1, 1) + arr.slice(0,n-1, 1)
			
func update_grid()->void:
	for n in range(8):
		for n2 in range(8):
			cookie_columns[n][n2].set_grid(n,n2)
			cookie_columns[n][n2].set_shift(Vector2(0,0))
			cookie_columns[n][n2].update_position()

func rotate_grid_row(row:int, distance:int)->void:
	#Rotate a grid row by a distance
	var stored_row := Array()
	for i in range(8):
		stored_row.append(cookie_columns[i][row])
	for i in range(8):
		var new_i = (i+distance)%8
		cookie_columns[i][row] = stored_row[new_i]
	#print(stored_row)

# Timer signal function
func exit_grace():
	in_grace = false
