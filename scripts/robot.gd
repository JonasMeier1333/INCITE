extends Node2D

@export var walk_speed = 30
@export var chase_speed = 60
@export var patrol_range = 50
@export var detect_range = 150
@export var attack_range = 15
@export var robot_health = 100

@onready var is_dead = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var punch_collision: CollisionShape2D = $Area2D2/Punch_Collision
@onready var player = get_tree().root.find_child("player",true,false)
@onready var bodencheck_r: RayCast2D = $"Bodencheck r"
@onready var bodencheck_l: RayCast2D = $"Bodencheck l"
@onready var body_collision: CollisionShape2D = $Area2D/Body_Collision



var start_x: float 
var patrol_dir = 1 
var is_attacking = false


	
	#Rückstoß
	#if health <= 0:
		#die()

func die():
	is_dead = true
	print("Roboter zerstört")
	# Todesanimation
	#await animation
	queue_free()


func _ready() -> void:
	start_x = global_position.x
	punch_collision.disabled = true # Hitbox am start aus
	
func _process(delta: float) -> void:
	
	if robot_health <= 0:
		die()
	
	
	#fake gravity
	if not (bodencheck_l.is_colliding() or bodencheck_r.is_colliding()):
		position.y -= -0.75
	
	

	#Pathfinding script
	if not player or is_attacking:
		return
	var distance = global_position.distance_to(player.global_position)
	
	if distance <= attack_range:
		start_attack()
	elif distance <= detect_range:
		chase(delta)
	else:
		patrol(delta)
		
#Verfolgung
func chase(delta:float):
	#Vorzeichen also Richtung zum Ritter rausfinden
	var dir_x = sign(player.global_position.x - global_position.x)		
	global_position.x += dir_x * chase_speed * delta
	animation_player.play("walking")
	update_facing(dir_x)
	
#patrouille

func patrol(delta:float):
	#Ziel berechnen basierend auf Startpunkt und Reichweite
	var target_x = start_x + (patrol_dir*patrol_range)
	var move_dir = sign(target_x-global_position.x)
	
	global_position.x += move_dir *walk_speed*delta
	
	animation_player.play("walking")
	update_facing(move_dir)
	
	
	# Wenn er nah am Ziel ist umdrehen
	
	if abs(global_position.x - target_x) <2: 
		patrol_dir *= -1

func start_attack():
	if is_attacking:
		return
	is_attacking = true 
	if is_attacking:
		punch_collision.disabled = false
	animation_player.play("punch")
	#Warten bis anim fertig
	await animation_player.animation_finished
	is_attacking = false





# Umdrehen von sprite

func update_facing(direction):
	if direction < 0:
		animated_sprite_2d.flip_h = true
		$Area2D2.scale.x = -1  
	elif direction > 0:
		animated_sprite_2d.flip_h = false
		$Area2D2.scale.x = 1






# Schaden bei körperberührung
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and is_attacking:
		Global.player_take_damage.emit(5)

#Schaden bei Angriff
func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.name == "player" and is_attacking:
		Global.player_take_damage.emit(10)
	



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "knight_weapons":
		print("aua")
		robot_health -= 20
		print("robot health", robot_health)
	
