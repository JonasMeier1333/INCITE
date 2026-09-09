extends Area2D

@onready var timer: Timer = $Timer
@onready var death_sound: AudioStreamPlayer2D = $"death sound"



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") :
		print("21, 22 Toad")
		death_sound.play()
		Engine.time_scale = 0.05
		timer.start()
		
		Global.deaths += 1



func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
#
