extends Control

@onready var music_slider: HSlider = $VBoxContainer/Music/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFX/SFXSlider

func _ready() -> void:
	var music_bus = AudioServer.get_bus_index("Music ")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	
	# Setze die Reglerpositionen auf den aktuellen db Wert der Audio Busse um db addtion zu verhindern
	music_slider.value = AudioServer.get_bus_volume_db(music_bus)
	sfx_slider.value = AudioServer.get_bus_volume_db(sfx_bus)

func _on_music_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music ")
	AudioServer.set_bus_volume_db(bus_index, value)
	if value == -30:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		

func _on_sfx_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, value)
	if value == -30:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
