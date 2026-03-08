extends Area2D

var is_overlapping := false


func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			if Input.is_action_just_pressed("playerEnter"):
				get_tree().change_scene_to_file("res://Scenes/Bunker.tscn")
