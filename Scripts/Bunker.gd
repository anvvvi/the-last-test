extends Node2D

var generation = []
var forced_room_dirs = {}
var start_col = 0
const CELL_SIZE = 320
const GRID_SIZE = 10

func _ready() -> void:
	fill_dirt()
	for i in range(GRID_SIZE):
		generation.append([])
		for j in range(GRID_SIZE):
			generation[i].append(0)
	start_col = randi_range(1, GRID_SIZE - 2)
	generation[1][start_col] = 1
	for i in range(1, GRID_SIZE - 2):
		for j in range(1, GRID_SIZE - 2):
			var isRoom = randi_range(0, 100)
			if isRoom < 35:
				generation[i][j] = 1
	connect_all_ones()
	resolve_corners()
	for row in generation:
		print(row)
	spawn_scenes()

func fill_dirt():
	var dirt = $Dirt
	for i in range (-1000,1000):
		for j in range (-1000, 1000):
			dirt.set_cell(Vector2i(i,j), 0  ,Vector2i(9,0))

func get_all_ones() -> Array:
	var points = []
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if generation[i][j] == 1:
				points.append(Vector2(i, j))
	return points

func draw_path(a: Vector2, b: Vector2) -> void:
	var row = int(a.x)
	var col = int(a.y)
	var target_row = int(b.x)
	var target_col = int(b.y)
	var col_step = 1 if target_col > col else -1
	while col != target_col:
		generation[row][col] = 1
		col += col_step
	var row_step = 1 if target_row > row else -1
	while row != target_row:
		generation[row][col] = 1
		row += row_step
	generation[row][col] = 1

func connect_all_ones() -> void:
	var points = get_all_ones()
	if points.size() < 2:
		return
	for i in range(points.size() - 1):
		draw_path(points[i], points[i + 1])

func get_neighbors(row: int, col: int) -> Dictionary:
	return {
		"up":    row > 0 and generation[row-1][col] >= 1,
		"down":  row < GRID_SIZE-1 and generation[row+1][col] >= 1,
		"left":  col > 0 and generation[row][col-1] >= 1,
		"right": col < GRID_SIZE-1 and generation[row][col+1] >= 1
	}

func count_neighbors(row: int, col: int) -> int:
	var n = get_neighbors(row, col)
	return int(n.up) + int(n.down) + int(n.left) + int(n.right)

func is_corner(row: int, col: int) -> bool:
	var n = get_neighbors(row, col)
	if count_neighbors(row, col) != 2:
		return false
	if (n.up or n.down) and (n.left or n.right):
		return true
	return false

func resolve_corners() -> void:
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if generation[i][j] == 1 and is_corner(i, j):
				var n = get_neighbors(i, j)
				var candidates = []
				if not n.up and i > 0:             candidates.append(Vector2(-1, 0))
				if not n.down and i < GRID_SIZE-1: candidates.append(Vector2(1, 0))
				if not n.left and j > 0:           candidates.append(Vector2(0, -1))
				if not n.right and j < GRID_SIZE-1:candidates.append(Vector2(0, 1))
				if candidates.size() > 0:
					var dir = candidates[randi() % candidates.size()]
					var room_row = i + int(dir.x)
					var room_col = j + int(dir.y)
					if generation[room_row][room_col] == 0:
						generation[room_row][room_col] = 2
						forced_room_dirs[Vector2(room_row, room_col)] = -dir

func get_t_rotation(row: int, col: int) -> float:
	var n = get_neighbors(row, col)
	if not n.down:  return 0.0
	if not n.up:    return PI
	if not n.right: return -PI / 2
	if not n.left:  return PI / 2
	return 0.0

func get_corridor_rotation(row: int, col: int) -> float:
	var n = get_neighbors(row, col)
	if n.left or n.right:
		return 0.0
	return PI / 2

func get_room_rotation(row: int, col: int) -> float:
	var n = get_neighbors(row, col)
	if n.right: return 0.0
	if n.left:  return PI
	if n.up:    return -PI / 2
	if n.down:  return PI / 2
	return 0.0

func get_forced_room_rotation(dir: Vector2) -> float:
	if dir == Vector2(0, 1):  return 0.0
	if dir == Vector2(0, -1): return PI
	if dir == Vector2(-1, 0): return -PI / 2
	if dir == Vector2(1, 0):  return PI / 2
	return 0.0

func spawn_scenes() -> void:
	var dead_ends = []
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if generation[i][j] == 1 and count_neighbors(i, j) == 1:
				dead_ends.append(Vector2(i, j))

	var guaranteed_room = Vector2(-1, -1)
	if dead_ends.size() > 0:
		guaranteed_room = dead_ends[randi() % dead_ends.size()]

	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var cell = generation[i][j]
			if cell == 0:
				continue

			var scene_path = ""
			var rotation_angle = 0.0

			if cell == 2:
				var room_num = randi_range(1, 3)
				scene_path = "res://Scenes/room" + str(room_num) + ".tscn"
				var key = Vector2(i, j)
				if forced_room_dirs.has(key):
					rotation_angle = get_forced_room_rotation(forced_room_dirs[key])
			else:
				var neighbors = count_neighbors(i, j)

				if neighbors == 4:
					scene_path = "res://Scenes/hallway1.tscn"

				elif neighbors == 3 or is_corner(i, j):
					scene_path = "res://Scenes/hallway2.tscn"
					rotation_angle = get_t_rotation(i, j)

				elif neighbors == 2:
					scene_path = "res://Scenes/hallway4.tscn"
					rotation_angle = get_corridor_rotation(i, j)

				elif neighbors == 1:
					var is_guaranteed = (Vector2(i, j) == guaranteed_room)
					if is_guaranteed or randf() < 0.5:
						var room_num = randi_range(1, 3)
						scene_path = "res://Scenes/room" + str(room_num) + ".tscn"
						rotation_angle = get_room_rotation(i, j)
					else:
						scene_path = "res://Scenes/hallway4.tscn"

			if scene_path != "":
				var instance = load(scene_path).instantiate()
				instance.position = Vector2(j * CELL_SIZE + CELL_SIZE / 2, i * CELL_SIZE + CELL_SIZE / 2)
				instance.rotation = rotation_angle
				add_child(instance)

	var player = load("res://Scenes/player.tscn").instantiate()
	player.position = Vector2(start_col * CELL_SIZE + CELL_SIZE / 2, 1 * CELL_SIZE + CELL_SIZE / 2)
	add_child(player)
	player.top_down = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("playerExit"):
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
		
