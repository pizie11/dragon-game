class_name C
extends Object
# C is for constant and thats okay with me

# Constants that are free to be modified
const COOKIE_SIZE = Vector2(64, 64)
const GRID_SIZE = Vector2(8,8)


# Constants that are derived from other constants, these shouldn't have to be changed
const COOKIE_WIDTH = int(COOKIE_SIZE.x)
const COOKIE_HEIGHT = int(COOKIE_SIZE.y)
const GRID_WIDTH = int(GRID_SIZE.x)
const GRID_HEIGHT = int(GRID_SIZE.y)

const CLONE_SOUTH = Vector2(0,COOKIE_HEIGHT * GRID_HEIGHT)
const CLONE_NORTH = -CLONE_SOUTH
const CLONE_EAST = Vector2(COOKIE_WIDTH * GRID_WIDTH, 0)
const CLONE_WEST = -CLONE_EAST
