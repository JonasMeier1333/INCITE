extends CharacterBody2D


@onready var anim_player: AnimationPlayer = $"pivot point/AnimatedSprite2D/AnimationPlayer"
@onready var is_dead = false
@onready var sprite: AnimatedSprite2D = $"pivot point/AnimatedSprite2D"
@onready var pivot_point: Node2D = $"pivot point"
@onready var hitbox_dd: CollisionShape2D = $"pivot point/psrooma dd/hitbox dd"
@onready var boden_check: RayCast2D = $"boden check"


@export var can_take_damage = false
@export var psrooma_health = 75
@export var speed = 30
@export var chase_speed = 90
@export var detect_range = 75
@export var attack_range = 25

var player_is_dead = false
var direction = 1
var player = null 
var is_hurt = false 


func _ready() -> void:
	Global.player_is_dead.connect(player_die)
	Global.player_attack.connect(hurt)

func hurt(attack_damage):
	
	if not is_hurt:
		play_hurt_anim()
		
	if not can_take_damage: return
	if is_dead : return
	psrooma_health -= attack_damage
	if psrooma_health <= 0:
		die()

func play_hurt_anim():
	if is_dead : return 
	is_hurt = true
	anim_player.play("take hit")		
	await anim_player.animation_finished
	is_hurt = false

func die():
	is_dead = true
	velocity.x = 0
	anim_player.clear_queue()
	anim_player.play("death")
	set_process(false)
	set_physics_process(false)
	await anim_player.animation_finished
	await get_tree().create_timer(3).timeout
	queue_free()
	
	
func player_die(player_just_died):
	player_is_dead = player_just_died


func _process(delta: float) -> void:
	if is_dead: return
	
	if is_on_floor() and not boden_check.is_colliding():
		direction *= -1
		pivot_point.scale.x = -1
	
	
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_wall():
		direction *= -1	
	
	 # spieler finden
	player = get_tree().get_first_node_in_group("player")
	
	
	
	if player :
		var distance = global_position.distance_to(player.global_position)
		
		if distance <= attack_range:
			attack()
			can_take_damage = true
		elif distance <= detect_range:
			can_take_damage = true
			chase(delta)
		else:
			patrol(delta)
	else:
		patrol(delta)
		can_take_damage = false
		
	move_and_slide()
	
func patrol(_delta):
	if is_dead : return
	
	
	if psrooma_health > 0:
		velocity.x = direction * speed
		
		if direction < 0:
			pivot_point.scale.x = -1
		else:
			pivot_point.scale.x = 1
		
		anim_player.play("run")
	
		if is_on_wall():
			direction *= -1
	
func chase(delta):

	if is_dead : return
	if psrooma_health > 0:
		var dir_to_player = (player.global_position - global_position).normalized()
		velocity.x = dir_to_player.x * chase_speed
	
		if velocity.x < 0:
			pivot_point.scale.x = -1
		else:
			pivot_point.scale.x = 1
		
		anim_player.play("run")
	
	
func attack():
	if is_dead:
		return
	if not is_hurt:
		if not player_is_dead:
			if psrooma_health > 0:
				velocity.x = 0
				await get_tree().create_timer(0.2).timeout
				hitbox_dd.disabled = false
				anim_player.play("attack")
				
		else:
			die()

	else:
		if is_dead : return
		hitbox_dd.disabled = true
		anim_player.play("take hit")


func _on_psrooma_dd_body_entered(body: Node2D) -> void:
	if body.name == "player": 
		Global.player_take_damage.emit(15)
