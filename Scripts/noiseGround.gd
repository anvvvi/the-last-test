extends Node2D
var noise
var ground_tile_id = 0
var ground
var sky
var max_height = 30
var min_height = -10
var width = 20
var player
var listOfHeights = []  # Index = X column, Value = ground height

const skyHeight = -200
const groundHeight = 200

# Track generation state
var last_generated_x = 0
var last_height = 6
var last_tile = 0
var generation_distance = 30
var tile_size = 32

func _ready():
	ground = $Ground
	sky = $Sky
	player = $Player
	player.position = Vector2(500, 0)

func _process(_delta):
	if int((player.position.x + generation_distance)/tile_size) > int (last_generated_x/tile_size):
		generate_terrain_from(last_generated_x, last_generated_x + generation_distance)

# PHASE 1 — Compute and store heights into listOfHeights
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

		# Store height — pad array if needed
		while listOfHeights.size() <= x:
			listOfHeights.append(0)
		listOfHeights[x] = height

	last_height = height


func smoothing(start_x: int, end_x: int):
	for x in range(start_x + 1, end_x - 1):
		if listOfHeights[x] + 1 == listOfHeights[x-1] && listOfHeights[x] + 1 == listOfHeights[x+1]:
			listOfHeights[x] += 1
			x+=2
		elif listOfHeights[x] - 1 == listOfHeights[x-1] && listOfHeights[x] - 1 == listOfHeights[x+1]:
			listOfHeights[x] -= 1
			x+=2

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

# Orchestrates both phases
func generate_terrain_from(start_x: int, end_x: int):
	generate_heights(start_x, end_x)
	smoothing(start_x,end_x)
	place_tiles(start_x, end_x)
	last_generated_x = end_x
