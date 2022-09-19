extends Node

var cookie_big = []

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
