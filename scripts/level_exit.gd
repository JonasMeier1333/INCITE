extends Area2D
@onready var player: CharacterBody2D = $"../player"


func _on_body_entered(body: Node2D) -> void:
	if body.name =="player":
		print("jojojojo")
		print(get_tree().current_scene.name)
		if get_tree().current_scene.name == "story level 1":
			get_tree().change_scene_to_file("res://scenes/story_level_2.tscn")
		elif get_tree().current_scene.name == "story level 2":
			get_tree().change_scene_to_file("res://scenes/story_level_3.tscn")
		elif get_tree().current_scene.name == "story level 3":
			get_tree().change_scene_to_file("res://scenes/control.tscn")
			Global.spielende = true
