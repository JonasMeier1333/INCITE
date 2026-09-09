extends Area2D

@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Global.health -= 5
		print (Global.health)
	if Global.health <= 0:
		Engine.time_scale = 0.4
		timer.start()
		print("Du bist gestorben")
		body.get_node("CollisionShape2D").queue_free()
		Global.deaths += 1
		

func _on_timer_timeout() -> void:
	Global.health = 100
	Engine.time_scale = 1
	get_tree().reload_current_scene()
	
