extends Node2D

# State vars
enum states {CLICK_STATE, DRAG_STATE, SCORE_STATE}
var current_state = states.CLICK_STATE

onready var timer := ($Timer as Timer)

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
			var cookie := CookieClass.new()
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

func _process(delta: float) -> void:
	match current_state:
		states.CLICK_STATE: # CLICK-> DRAG
			if (have_click and is_in_box(mouse_position_start, north,south,east, west)):
				print("CLICK->DRAG")
				var start_cookie := get_grid_of_position(mouse_position_start)
				print(start_cookie)
				
				for cookie in cookie_columns[start_cookie.y]:
					cookie_listY.append(cookie)
				for cookie_column in cookie_columns:
					cookie_listX.append(cookie_column[start_cookie.x])
					
				mouse_position_end = Vector2(-1,-1)
				mouse_delta = Vector2()
				current_state = states.DRAG_STATE
				return
		states.DRAG_STATE:
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
				mouse_position_start = Vector2()
				current_state = states.SCORE_STATE
				cookie_listX = []
				cookie_listY = []
				have_click = false
				in_grace = true
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
	
# Timer signal function
func exit_grace():
	in_grace = false
