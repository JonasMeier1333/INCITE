extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	game_manager.add_point()
	animation_player.play("Pickup")
	# queue_free() func  wird hier nicht im code Aufgerufen sondern in der Animation 
	#des sounds, der für die richtige Abspielung des Sounds da ist
	#innerhalb der animation wird in der spur functions die queue_free() aufgerufen
