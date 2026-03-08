extends Node2D

var ground_tile_id = 0
var ground
var sky
var clouds
var max_height = 30
var min_height = -10
var width = 20
var player
var listOfHeights = {}  # Changed to Dictionary to support negative x keys

const skyHeight = -200
const groundHeight = 200

var entrance_scene = preload("res://Scenes/entrance_bunker.tscn")
var entrance_instance = null

var last_generated_x = 0
var first_generated_x = 0
var last_height = 6
var first_height = 6  # anchor for leftward generation
var last_tile = 0
var first_tile = 0
var generation_distance = 30
var tile_size = 32

func _ready():
	ground = $Ground
	sky = $Sky
	player = $Player
	clouds = $Clouds
	generate_terrain_from(last_generated_x, last_generated_x + generation_distance)
	# Place player on top of tile after terrain is generated
	var player_tile_x = 0
	var ground_y = listOfHeights[player_tile_x]
	player.position = Vector2(player_tile_x * tile_size, ground_y * tile_size - tile_size)
	load_entrance(0 * tile_size, listOfHeights[0] * tile_size - tile_size)

func _process(_delta):
	# Generate to the right
	if (player.position.x / tile_size) + generation_distance > last_generated_x:
		generate_terrain_from(last_generated_x, last_generated_x + generation_distance)
	# Generate to the left
	if (player.position.x / tile_size) - generation_distance < first_generated_x:
		var new_start = first_generated_x - generation_distance
		generate_terrain_from_left(new_start, first_generated_x)
		first_generated_x = new_start
	#print(player.position / tile_size)

func load_entrance(px: int, py: int):
	entrance_instance = entrance_scene.instantiate()
	add_child(entrance_instance)
	entrance_instance.position = Vector2(px, py)

func generate_heights(start_x: int, end_x: int):
	var height = last_height
	var hillines = 5
	var step
	for x in range(start_x, end_x):
		step = randi_range(0, 150)
		if hillines > 20 or x % 5 == 0:
			hillines = randi_range(0, 100)
			if hillines < 20:
				step *= 1.3
			if hillines > 20 && hillines < 50:
				step *= 0.7
		if step > 100 && height - 1 > min_height:
			height -= 1
		elif step <= 100 && step > 50 && height + 1 < max_height:
			height += 1
		listOfHeights[x] = height
	last_height = height

# Generate heights right-to-left (leftward), branching from first_height
func generate_heights_left(start_x: int, end_x: int):
	var height = first_height
	var hillines = 5
	var step
	for x in range(end_x - 1, start_x - 1, -1):
		step = randi_range(0, 150)
		if hillines > 20 or x % 5 == 0:
			hillines = randi_range(0, 100)
			if hillines < 20:
				step *= 1.3
			if hillines > 20 && hillines < 50:
				step *= 0.7
		if step > 100 && height - 1 > min_height:
			height -= 1
		elif step <= 100 && step > 50 && height + 1 < max_height:
			height += 1
		listOfHeights[x] = height
	first_height = height

func smoothing(start_x: int, end_x: int):
	for x in range(start_x + 1, end_x - 1):
		if listOfHeights.has(x-1) && listOfHeights.has(x) && listOfHeights.has(x+1):
			if listOfHeights[x] + 1 == listOfHeights[x-1] && listOfHeights[x] + 1 == listOfHeights[x+1]:
				listOfHeights[x] += 1
				x += 2
			elif listOfHeights[x] - 1 == listOfHeights[x-1] && listOfHeights[x] - 1 == listOfHeights[x+1]:
				listOfHeights[x] -= 1
				x += 2
		var chanche_of_entrance = randi_range(0,100)
		if listOfHeights[x] == listOfHeights[x+1] && listOfHeights[x] == listOfHeights[x-1] && chanche_of_entrance < 20:
			load_entrance(x*tile_size , listOfHeights[x] * tile_size - tile_size)

func place_tiles(start_x: int, end_x: int):
	var tileNumber = last_tile
	for x in range(start_x, end_x):
		if tileNumber % 8 == 0 && tileNumber != 0:
			tileNumber = 0
		else:
			tileNumber += 1
		var height = listOfHeights[x]
		ground.set_cell(Vector2i(x, height), 0, Vector2i(tileNumber, 0))
		for y in range(height + 1, groundHeight):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(9, 0))
		for y in range(skyHeight, height):
			sky.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
	last_tile = tileNumber

func place_tiles_left(start_x: int, end_x: int):
	var tileNumber = first_tile
	for x in range(end_x - 1, start_x - 1, -1):
		if tileNumber % 8 == 0 && tileNumber != 0:
			tileNumber = 0
		else:
			tileNumber += 1
		var height = listOfHeights[x]
		ground.set_cell(Vector2i(x, height), 0, Vector2i(tileNumber, 0))
		for y in range(height + 1, groundHeight):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(9, 0))
		for y in range(skyHeight, height):
			sky.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
	first_tile = tileNumber

func generate_terrain_from(start_x: int, end_x: int):
	generate_heights(start_x, end_x)
	smoothing(start_x, end_x)
	place_tiles(start_x, end_x)
	last_generated_x = end_x

# Leftward generation
func generate_terrain_from_left(start_x: int, end_x: int):
	generate_heights_left(start_x, end_x)
	smoothing(start_x, end_x)
	place_tiles_left(start_x, end_x)
