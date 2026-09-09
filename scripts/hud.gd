extends CanvasLayer

# biler reinladen ändert sich je nach odrdner struktur vorsichtig veränder!!!!!
@onready var timer: Timer = $Timer

@onready var heart_full = preload("res://assets/sprites/tile_0132.png")
@onready var heart_half = preload("res://assets/sprites/tile_0133.png")
@onready var heart_empty = preload("res://assets/sprites/tile_0134.png")

#3 sprites also herzen in eine gemeinsame liste

@onready var heart_nodes = $HeartContainer.get_children()

func _ready():
	Global.health_changed.connect(update_hearts)
	update_hearts()
	
func update_hearts():
	for i in range(heart_nodes.size()):
		var threshold = (i+1)*10
		
		if Global.health >= threshold:
			heart_nodes[i].texture = heart_full
			
		elif Global.health >= threshold-5:
			heart_nodes[i].texture = heart_half
			
		else:
			heart_nodes[i].texture = heart_empty
			
	if Global.health <= 0:
		die()
	
func die():
	timer.start()
	Engine.time_scale = 0.4
	print("Spieler gestorben")
	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	Global.health = 30
	get_tree().reload_current_scene()
