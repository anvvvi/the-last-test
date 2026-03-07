extends Node2D

var noise
var ground_tile_id = 0  # Replace with your TileSet tile ID
var ground
var sky
var max_height = 10
var min_height = 0
var width = 20

var listOfHeights = []

func _ready():
	ground = $Ground
	sky = $Sky
	generate_terrain()
#
func generate_terrain():
	var height = 6
	var hillines = 5
	var step
	var tileNumber = 0
	for generated_terrain in range(width):
		if tileNumber%8 == 0 && tileNumber != 0:
			tileNumber = 0
		else:
			tileNumber += 1
		step =  randi_range(0,150)
		if hillines > 20 or generated_terrain % 5 == 0:
			hillines = randi_range(0,100)
			if hillines < 20 :
				step *= 1.3
			if hillines > 20 && hillines < 50:
				step *= 0.7
		if step > 100 && height-1 > min_height:
			height -= 1
		else: 
			if step <= 100 && step > 50 && height+1 < max_height:
				height += 1
		ground.set_cell(Vector2i(generated_terrain,height), 0 , Vector2i(tileNumber,0))
		for y in range(height + 1,max_height):
			ground.set_cell(Vector2i(generated_terrain,y) , 0, Vector2i(9,0))
		for y in range(min_height, height):
			sky.set_cell(Vector2i(generated_terrain,y) , 1, Vector2i(0,0))
		listOfHeights[generated_terrain] = height
		
		
		
		
