extends Node2D
# displays a grid of cookies in a scene

# State vars
enum States {CLICK_STATE, DRAG_STATE, SCORE_STATE}
var current_state = States.CLICK_STATE

onready var timer := ($Timer as Timer)

var cookie_types := [Cookie, CookieRed, CookieGreen]

# mouse start and end positions of drag
var mouse_position_start := Vector2()
var mouse_position_end := Vector2()

# Cookie grid matrix
var cookie_matrix : CookieMatrix

# Grid boundaries
var boundary : Rect2

# vars for click state
var start_cookie := Vector2I.new()
var end_cookie := Vector2I.new()

# vars for drag state
var move_row: bool
var move_column: bool
var mouse_delta := Vector2()
var chosen_row := CookieArray.new()
var chosen_column := CookieArray.new()

# Boolean flags
var have_click := false
var in_grace := false

func _ready() -> void:
	cookie_matrix = CookieMatrix.new(C.GRID_WIDTH, C.GRID_HEIGHT, cookie_types)
	for cookie in cookie_matrix.get_loose_cookies():
		add_child(cookie)
	print(cookie_matrix.get_cookie(Vector2(7,7)))
	boundary = Rect2(global_position, Vector2(C.COOKIE_WIDTH * C.GRID_WIDTH, 
												C.COOKIE_HEIGHT * C.GRID_HEIGHT))


func _process(_delta: float) -> void:
	match current_state:
		States.CLICK_STATE: # CLICK-> DRAG
			_click_to_drag()
		States.DRAG_STATE:
			_do_drag()
			_drag_to_score()
		States.SCORE_STATE:
			_score_to_click()


### STATE FUNCTIONS
# Click state to drag state transition
func _click_to_drag() -> void:
	if (have_click and is_in_box(mouse_position_start, boundary)):
		print("CLICK->DRAG")
		start_cookie = get_grid_of_position(mouse_position_start)
		print("(",start_cookie.x,",",start_cookie.y,")")
		chosen_row = cookie_matrix.get_cookie_row(start_cookie.y)
		chosen_column = cookie_matrix.get_cookie_column(start_cookie.x)
		# Create clones for scrolling
		chosen_row.make_x_clones()
		chosen_column.make_y_clones()
		# Set vars for new state
		mouse_position_end = Vector2()
		mouse_delta = Vector2()
		current_state = States.DRAG_STATE


# Doing dragging update in drag state
func _do_drag() -> void:
	# handling cookie movement in drag state
	move_row = false
	move_column = false
	if abs(mouse_delta.y) < abs(mouse_delta.x):
		move_row = true
	else:
		move_column = true	
	if move_row:
		chosen_row.set_global_shift(Vector2(mouse_delta.x,0))
	else:
		chosen_row.reset_global_shift(true,false)
	if move_column:
		chosen_column.set_global_shift(Vector2(0,mouse_delta.y))
	else:
		chosen_column.reset_global_shift(false,true)


# Drag state to scoring state
func _drag_to_score() -> void:
	if have_click and mouse_delta.length() > 0 : # DRAG-> SCORE
		print("DRAG->SCORE")
		end_cookie = get_grid_of_position(mouse_position_end)
		# TODO turn this into Vector2I helper adding, cant be in class due to
		# cycle restriction
		var distance := Vector2I.new(end_cookie.x-start_cookie.x, 
									end_cookie.y-start_cookie.y)
		# move all cookies 
		if move_row and distance.x != 0: 
			cookie_matrix.rotate_matrix_row(start_cookie.y, -distance.x)
			#chosen_row.update_array_row(start_cookie.y)
		if move_column and distance.y != 0:
			cookie_matrix.rotate_matrix_column(start_cookie.x, -distance.y)
			#chosen_column.update_array_column(start_cookie.x)
		print("moving (",distance.x,",",distance.y, ") spots")	
		# Do redundancy check on the whole grid matrix HERE
		# mostly for the cookie grid var
		cookie_matrix.update()
		# Remove visual clones
		chosen_row.delete_clones()
		chosen_column.delete_clones()
		# Reset certain vars
		mouse_position_start = Vector2()
		chosen_row = CookieArray.new()
		chosen_column = CookieArray.new()
		have_click = false
		in_grace = true
		current_state = States.SCORE_STATE
		timer.start()


func _score_to_click():
	print("SCORE->CLICK")
	current_state = States.CLICK_STATE
	have_click = false


### OTHER/HELPER FUNCTIONS
# Handle Mouse input
func _input(event: InputEvent) -> void:
	have_click = false
	if event is InputEventMouseButton and not in_grace:
		var button_event := (event as InputEventMouseButton)
		if current_state == States.CLICK_STATE:
			mouse_position_start = button_event.global_position
			have_click = true
		elif current_state == States.DRAG_STATE:
			mouse_position_end = button_event.global_position
			have_click = true
	elif event is InputEventMouseMotion:
		var motion_event := (event as InputEventMouseMotion)
		if current_state == States.DRAG_STATE:
			mouse_delta += motion_event.relative
			return


# returns whether or not a click is within a north/south/east/west box! 
# (COULD GO TO LIBRARY)
func is_in_box(pos: Vector2, box: Rect2) -> bool:
	return box.has_point(pos)


# returns the grid position of a position
func get_grid_of_position(pos: Vector2) -> Vector2I:
	var x_val:= int(floor((pos.x - global_position.x) / C.COOKIE_WIDTH))
	var y_val:= int(floor((pos.y - global_position.y) / C.COOKIE_HEIGHT))
	return Vector2I.new(x_val, y_val)


# Timer signal function
func exit_grace() -> void:
	in_grace = false
