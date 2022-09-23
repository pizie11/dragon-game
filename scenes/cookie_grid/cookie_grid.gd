extends Node2D

enum states {CLICK_STATE, DRAG_STATE, SCORE_STATE}
var current_state = states.CLICK_STATE

var mouse_position_start = Vector2(-1, -1)
var mouse_position_end = Vector2(-1, -1)

var cookie_big = []
var north
var south
var east
var west

var start_cookie = Vector2()
var mouse_delta = Vector2()
var cookie_listY = []
var cookie_listX = []

func _ready() -> void:
	for n in range(8):
		var cookie_small = []
		for n2 in range(8):
			var cookie = CookieClass.new()
			cookie.gridX = n
			cookie.gridY = n2
			cookie.update_position()
			cookie_small.append(cookie)
			add_child(cookie)
		cookie_big.append(cookie_small)
	print(cookie_big[7][7])
	north = global_position.y
	south = global_position.y + 64 * 8
	east = global_position.x + 64 * 8
	west = global_position.x

func _process(delta: float) -> void:
	match current_state:
		states.CLICK_STATE:
			if (mouse_position_start.x > west and mouse_position_start.x < east and 
			mouse_position_start.y > north and mouse_position_start.y < south):
				var found_cookie = Vector2((floor((mouse_position_start.x - global_position.x) /64)),
				(floor((mouse_position_start.y - global_position.y) /64)))
				print(found_cookie)
				start_cookie.x = found_cookie.y
				start_cookie.y = found_cookie.x
				for cookie in cookie_big[start_cookie.y]:
					cookie_listY.append(cookie)
				for cookie_column in cookie_big:
					cookie_listX.append(cookie_column[start_cookie.x])
				mouse_position_end = Vector2(-1,-1)
				current_state = states.DRAG_STATE
				return
		states.DRAG_STATE:
			for cookie in cookie_listY:
				cookie.offsetY = mouse_delta.y
				cookie.update_position()
			for cookie in cookie_listX:
				cookie.offsetX = mouse_delta.x
				cookie.update_position()
		states.SCORE_STATE:
			pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if current_state == states.CLICK_STATE:
			mouse_position_start = event.global_position
			return
		elif current_state == states.DRAG_STATE:
			mouse_position_end = event.global_position
			return
	elif event is InputEventMouseMotion:
		if current_state == states.DRAG_STATE:
			mouse_delta += event.relative
			return
