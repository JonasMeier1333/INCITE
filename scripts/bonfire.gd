extends Area2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var player_in_range = false
@onready var label: Label = $Label

func _process(delta: float) -> void:
	# Prüfen ob Spieler da ist und E drückt
	if player_in_range and Input.is_action_just_pressed("interact"):
		save_at_bonfire()
		Global.bonfire_regen.emit(100)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_range = true
		label.show()
		
		audio_player.volume_db = -10
		audio_player.play()


func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_in_range = false
		label.hide()
		
		var tween = create_tween()
		tween.tween_property(audio_player, "volume_db", -40.0 , 1.0)
		tween.finished.connect(audio_player.stop)
	
func save_at_bonfire():
	Global.aktueller_pfad = get_tree().current_scene.scene_file_path
	var new_save = SaveData.new()
	
	new_save.last_bonfire_position = global_position
	new_save.player_health = 100
	
	var error = ResourceSaver.save(new_save, "user://savegame.tres")
	
	if error == OK:
		print("Gespeichert! bei " ,global_position)
		label.text = "Saved Game"
		await get_tree().create_timer(2).timeout
		label.text = "E to Rest"
