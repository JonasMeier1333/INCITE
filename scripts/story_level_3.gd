extends Node2D

@onready var player: CharacterBody2D = $player
@onready var background_sounds: AudioStreamPlayer2D = $"background sounds"
@onready var water_background_sounds: AudioStreamPlayer2D = $"water background sounds"




func _ready() -> void:
	#DirAccess.remove_absolute("user://savegame.tres")
	if FileAccess.file_exists("user://savegame.tres"):
		var saved_data = ResourceLoader.load("user://savegame.tres")
		
		if "last_bonfire_position" in saved_data:
			player.global_position = saved_data.last_bonfire_position
			print("spawn at bonfire")
		else:
			print ("Warning savegame without position information")
	else:
		print("there are no savegames")
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not background_sounds.is_playing():
		background_sounds.play()
	
	if not water_background_sounds.is_playing():
		water_background_sounds.play()
	
