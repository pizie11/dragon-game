extends Node2D
# displays a grid of cookies in a scene

# State vars
enum States {CLICK_STATE, DRAG_STATE, SCORE_STATE}
var current_state = States.CLICK_STATE

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
var cookie_matrix : CookieMatrix

# Grid boundaries
var north: float
var south: float
var east: float
var west: float

# vars for click state
var start_cookie := Vector2I.new()
var end_cookie := Vector2I.new()

# vars for drag state
var move_x: bool
var move_y: bool
var mouse_delta := Vector2()
var cookie_listY := CookieArray.new()
var cookie_listX := CookieArray.new()

# Boolean flags
var have_click := false
var in_grace := false

func _ready() -> void:
	cookie_matrix = CookieMatrix.new(GRID_WIDTH, GRID_HEIGHT, cookie_types)
	for cookie in cookie_matrix.get_loose_cookies():
		add_child(cookie)
	print(cookie_matrix.get_cookie(Vector2(7,7)))
	north = global_position.y
	south = global_position.y + COOKIE_SIZE_Y * GRID_HEIGHT
	east = global_position.x + COOKIE_SIZE_X * GRID_WIDTH
	west = global_position.x


func _process(_delta: float) -> void:
	match current_state:
		States.CLICK_STATE: # CLICK-> DRAG
			_click_to_drag()
		States.DRAG_STATE:
			_do_drag()
			_drag_to_score()
		States.SCORE_STATE:
			print("SCORE->CLICK")
			current_state = States.CLICK_STATE
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
		cookie_listX = cookie_matrix.get_cookie_row(start_cookie.x)
		cookie_listY = cookie_matrix.get_cookie_column(start_cookie.y)
		# Create clones for scrolling
		cookie_listX.make_x_clones()
		cookie_listY.make_y_clones()
		# Set vars for new state
		mouse_position_end = Vector2(-1,-1)
		mouse_delta = Vector2()
		current_state = States.DRAG_STATE


# Doing dragging update in drag state
func _do_drag() -> void:
	# handling cookie movement in drag state
	move_x = false
	move_y = false
	if abs(mouse_delta.y) > abs(mouse_delta.x):
		move_y = true
	else:
		move_x = true
	if move_y:
		cookie_listY.set_global_shift(Vector2(0,mouse_delta.y))
	else:
		cookie_listY.reset_global_shift(false,true)
	if move_x:
		cookie_listX.set_global_shift(Vector2(mouse_delta.x,0))
	else:
		cookie_listX.reset_global_shift(true,false)


# Drag state to scoring state
func _drag_to_score() -> void:
	if have_click and mouse_delta.length() > 0 : # DRAG-> SCORE
		print("DRAG->SCORE")
		var found_cookie := get_grid_of_position(mouse_position_end)
		end_cookie = Vector2I.new(found_cookie.y,found_cookie.x)
		# TODO turn this into Vector2I helper adding, cant be in class due to
		# cycle restriction
		var distance := Vector2I.new(end_cookie.x-start_cookie.x, 
									end_cookie.y-start_cookie.y)
		# move all cookies 
		if move_y and distance.x != 0: 
			cookie_matrix.rotate_matrix_column(start_cookie.y, -distance.x)
		if move_x: 
			cookie_matrix.rotate_matrix_row(start_cookie.x, -distance.y)
		print("moving (",-distance.x,",",-distance.y, ") spots")	
		# Do redundancy check on the whole grid matrix HERE
		# mostly for the cookie grid var
		cookie_matrix.update()
		# Remove visual clones
		cookie_listX.delete_clones()
		cookie_listY.delete_clones()
		# Reset certain vars
		mouse_position_start = Vector2()
		cookie_listX = CookieArray.new()
		cookie_listY = CookieArray.new()
		have_click = false
		in_grace = true
		current_state = States.SCORE_STATE
		timer.start()


### OTHER/HELPER FUNCTIONS
# Handle Mouse input
func _input(event: InputEvent) -> void:
	have_click = false
	if event is InputEventMouseButton and not in_grace:
		var button_event := (event as InputEventMouseButton)
		if current_state is States.CLICK_STATE:
			mouse_position_start = button_event.global_position
			have_click = true
		elif current_state is States.DRAG_STATE:
			mouse_position_end = button_event.global_position
			have_click = true
	elif event is InputEventMouseMotion:
		var motion_event := (event as InputEventMouseMotion)
		if current_state is States.DRAG_STATE:
			mouse_delta += motion_event.relative
			return


# returns whether or not a click is within a north/south/east/west box! 
# (COULD GO TO LIBRARY)
func is_in_box(pos: Vector2, n: float, s: float, e: float, w: float) -> bool:
	return pos.x > w and pos.x < e and pos.y > n and pos.y < s


# returns the grid position of a position
func get_grid_of_position(pos: Vector2) -> Vector2I:
	var x_val:= int(floor((pos.x - global_position.x) / COOKIE_SIZE_X))
	var y_val:= int(floor((pos.y - global_position.y) / COOKIE_SIZE_Y))
	return Vector2I.new(x_val, y_val)


# Timer signal function
func exit_grace() -> void:
	in_grace = false
