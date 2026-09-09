extends Control

@onready var music_bus = AudioServer.get_bus_index("Music ")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")
@onready var ambient_bus = AudioServer.get_bus_index("Ambient")
@onready var reverb_bus1 = AudioServer.get_bus_index("ReverbBus1")
@onready var reverb_bus2 = AudioServer.get_bus_index("ReverbBus2")

@onready var h_slider_musik: HSlider = $MarginContainer/VBoxContainer/Musik/HSlider_musik
@onready var h_slider_ambient: HSlider = $MarginContainer/VBoxContainer/Ambient/HSlider_ambient
@onready var h_slider_sfx: HSlider = $MarginContainer/VBoxContainer/SFX/HSlider_sfx






func _ready() -> void:
	var music_db = AudioServer.get_bus_volume_db(music_bus)
	h_slider_musik.value = db_to_linear(music_db)
	
	var sfx_db = AudioServer.get_bus_volume_db(sfx_bus)
	h_slider_sfx.value = db_to_linear(sfx_db)
	
	var ambient_db = AudioServer.get_bus_volume_db(ambient_bus)
	h_slider_ambient.value = db_to_linear(ambient_db)


func _on_h_slider_musik_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/control.tscn")


func _on_h_slider_ambient_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(ambient_bus, linear_to_db(value))


func _on_h_slider_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	AudioServer.set_bus_volume_db(reverb_bus1, linear_to_db(value))
	AudioServer.set_bus_volume_db(reverb_bus2, linear_to_db(value))


func _on_controlls_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/controlls.tscn")
