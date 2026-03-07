extends Node2D

var noise
var ground_tile_id = 0
var ground
var sky
var max_height = 10
var min_height = 0
var width = 20
var player
var listOfHeights = []

# Track generation state
var last_generated_x = 0       # The furthest X column generated so far
var last_height = 6 
var last_tile =  0          # Carry height between chunks so terrain is seamless
var generation_distance = 30   # How many tiles ahead of player to generate
var tile_size = 32             # Match your TileSet tile size in pixels

func _ready():
	ground = $Ground
	sky = $Sky
	player = $Player
	player.position = Vector2(100, 0)
	#generate_terrain_from(0, width)
	

func _process(_delta):
	#print(int(player.position.x + generation_distance) , ' ' , tile_size + last_generated_x)
	#print( (player.position.x + generation_distance)/tile_size , ' ' , last_generated_x/tile_size)
	if (player.position.x + generation_distance)/tile_size > last_generated_x/tile_size:
		print((player.position.x + generation_distance)/tile_size , ' ' , last_generated_x/tile_size)
		generate_terrain_from(last_generated_x, last_generated_x + generation_distance)

func generate_terrain_from(start_x: int, end_x: int):
	var height = last_height   # Continue from where we left off
	var hillines = 5
	var step
	var tileNumber = last_tile
	for generated_terrain in range(start_x, end_x):
		if tileNumber % 8 == 0 && tileNumber != 0:
			tileNumber = 0
		else:
			tileNumber += 1
		step = randi_range(0, 150)
		if hillines > 20 or generated_terrain % 5 == 0:
			hillines = randi_range(0, 100)
			if hillines < 20:
				step *= 1.3
			if hillines > 20 && hillines < 50:
				step *= 0.7
		if step > 100 && height - 1 > min_height:
			height -= 1
		else:
			if step <= 100 && step > 50 && height + 1 < max_height:
				height += 1
		ground.set_cell(Vector2i(generated_terrain, height), 0, Vector2i(tileNumber, 0))
		for y in range(height + 1, max_height):
			ground.set_cell(Vector2i(generated_terrain, y), 0, Vector2i(9, 0))
		for y in range(min_height, height):
			sky.set_cell(Vector2i(generated_terrain, y), 1, Vector2i(0, 0))
	last_tile = tileNumber
	last_generated_x = end_x   # Update the frontier
	last_height = height        # Save height for next chunk's continuityd  d
