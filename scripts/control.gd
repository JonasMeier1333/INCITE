extends Control
@onready var fehler_melder: Label = $"Fehler Melder"

@onready var tode: Label = $MarginContainer/VBoxContainer/Tode

func _process(delta: float) -> void:
	tode.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tode.text = ("Deaths " + str(Global.deaths))



func _on_play_pressed() -> void:
	
	Global.from_mm = true
	Global.aktueller_pfad	 = ""
	
	
	Global.deaths = 0
	get_tree().change_scene_to_file("res://scenes/story_level_1.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_continue_pressed() -> void:
	if Global.aktueller_pfad != "" and not Global.spielende:
		get_tree().change_scene_to_file(Global.aktueller_pfad)
	else:
		print("Kein Spielstand vorhanden")
		fehler_melder.text = "Kein Spielstand vorhanden !"
		await get_tree().create_timer(2).timeout
		fehler_melder.text = ""
