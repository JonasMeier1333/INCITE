extends CharacterBody2D

@export var Wallrecoil = 200
@export var Wallglide = 50
@export var SPEED = 140.0
@export var Walljump = -350
@export var JUMP_VELOCITY = -340.0
@export var ACCELERATION = 700.0  # Wie schnell er Fahrt aufnimmt
@export var FRICTION = 500.0    # Wie schnell er bremst (Reibung)
@export var AIR_RESISTANCE = 100
@export var is_attacking = false
@export var knight_health = 100
@export var knight_stamina = 100
@export var dash_speed = 400
@export var fall_damage_multiplier = 0.1
const LONG_PRESS_TIME = 0.4

@onready var run_sound: AudioStreamPlayer2D = $"run sound"
@onready var death_sound: AudioStreamPlayer2D = $death

@onready var effect_knight: CollisionShape2D = $"Pivot Point/knight_effects/effect"
@onready var stamina_fast_recover_timer: Timer = $"stamina fast recover timer"
@onready var weapon: CollisionShape2D = $"Pivot Point/knight_weapons/weapon"
@onready var attack_hold_time = 0.0
@onready var stamina_regen_timer: Timer = $"stamina regen timer"
@onready var pivot_point: Area2D = $"Pivot Point"
@onready var health_bar: TextureProgressBar = $"../HUD/Health bar"
@onready var stamina_bar: TextureProgressBar = $"../HUD/Stamina bar"
@onready var wall_check_1: RayCast2D = $"Pivot Point/Wall Check 1"


@onready var boden_check: RayCast2D = $"boden check"
@onready var sound_death: AudioStreamPlayer2D = $death

@onready var camera_2d: Camera2D = $Camera2D
@onready var animation_player: AnimationPlayer = $"Pivot Point/AnimationPlayer"
@onready var sprite: AnimatedSprite2D = $"Pivot Point/AnimatedSprite2D"
var is_dying = false
var is_hurt = false
var is_dashing = false
var load_new_level = false

func _ready() -> void:
	
	if Global.from_mm == true or Global.spielende:
		print("debug für erster start bei 0,0")
		await get_tree().create_timer(0.01).timeout
		global_position = Vector2(0, 0)
		
		Global.spielende = false
		Global.from_mm = false

	Global.player_take_damage.connect(knight_damage1)
	print(knight_health)
	weapon.disabled = true
	
	Global.bonfire_regen.connect(bonfire_regen_effect)
	


func bonfire_regen_effect(regen):
	knight_health = regen
	knight_stamina = regen
	health_bar.value = knight_health
	stamina_bar.value = knight_stamina

func knight_damage1 (damage):
	death_sound.play()
	knight_health -= damage
	health_bar.value = knight_health
	
	if knight_health <= 0 and not is_dying:
		is_dying = true
		Global.deaths += 1
		animation_player.play("death")
		death_sound.play()

		
		var tree = get_tree()
		await animation_player.animation_finished
		knight_health = 100 
		is_dying = false
		tree.reload_current_scene()
	else: 
		if not is_hurt:
			play_hurt_anim()
			
func play_hurt_anim():
	is_hurt = true
	animation_player.play("hurt")
	await animation_player.animation_finished
	is_hurt = false
			
func stamina_drain(drain):
	knight_stamina -= drain
	knight_stamina = max(knight_stamina,0)
	stamina_bar.value = knight_stamina
	stamina_regen_timer.start()
	stamina_fast_recover_timer.start()


func _physics_process(delta: float) -> void:
	
	# traceback ins MM 
	if Input.is_action_just_pressed("mainmenu"):
		get_tree().change_scene_to_file("res://scenes/control.tscn")
	
	if is_attacking:
		weapon.disabled = false
	# stamina regeneration
	if stamina_regen_timer.is_stopped() and knight_stamina < 100 and not stamina_fast_recover_timer.is_stopped():
		knight_stamina += 5*delta
		# aussuchen zwischen kleineren werten damit kein überschuss is
		knight_stamina = min(knight_stamina, 100)
		stamina_bar.value = knight_stamina
	elif stamina_fast_recover_timer.is_stopped() and knight_stamina < 100:
		knight_stamina += 10*delta
		knight_stamina = min(knight_stamina,100)
		stamina_bar.value = knight_stamina
		
	if knight_health <= 0:
		Global.player_is_dead.emit(true)
		_play_if_new("death")
		var tree = get_tree()
		await get_tree().create_timer(5).timeout
		tree.reload_current_scene()
	
	
	var direction := Input.get_axis("move_left", "move_right")
	#walljump
	wall_check_1.target_position.x = 20

	
	if wall_check_1.is_colliding() and not is_on_floor():
		
		var wall_normal = Vector2.ZERO
		
		if wall_check_1.is_colliding():
			wall_normal = wall_check_1.get_collision_normal()
		
		#var wall_normal = wall_check.get_collision_normal().x
		
		if velocity.y > 0:
			velocity.y = Wallglide
	
		if (direction and wall_normal.x<0) or (direction<0 and wall_normal.x>0):
			if Input.is_action_just_pressed("jump"):
				velocity.y = Walljump 
				velocity.x = Wallrecoil * wall_normal.x
	
	 
	if not is_on_floor() :
		velocity += get_gravity() * delta 
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() ) :
		velocity.y = JUMP_VELOCITY
		
		
	if Input.is_action_just_pressed("dash"):
		dash()
	#Überprüfe welcher Angriff also light oder heavy :D	
	if Input.is_action_pressed("attack"):
		attack_hold_time += delta
		
		
	if Input.is_action_just_released("attack"):
		if not is_attacking:
			if abs(velocity.x) < 100:
				if attack_hold_time >= LONG_PRESS_TIME:
					slash() 
				else:
					sword()
			else:
				run_attack()
		attack_hold_time = 0.0

	var current_accel = ACCELERATION if is_on_floor() else ACCELERATION * 0.4
	
	if direction != 0 : 
		velocity.x = move_toward(velocity.x, direction *SPEED, current_accel*delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x,0, FRICTION*delta)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_RESISTANCE*delta)

	move_and_slide()
	
	if not is_attacking:
		update_animations()
	
func run_attack():
	if knight_stamina > 25:
		is_attacking = true
		stamina_drain(30)
		animation_player.play("run attack")
		await animation_player.animation_finished
		is_attacking = false

func sword():
	if knight_stamina >= 12:
		is_attacking = true
		stamina_drain(12)
		animation_player.play("attack 1")
		await get_tree().create_timer(0.1).timeout
		await animation_player.animation_finished
		is_attacking = false
	
func slash():
	if knight_stamina >= 35:
		is_attacking = true
		stamina_drain(25)
		 #Dash Effekt bei slash
		var dash_direction = 1 if not pivot_point.scale.x == -1 else -1
		velocity.x = dash_direction * 75
		animation_player.play("attack combo",-1,1.5)
		_screen_shake(4.0, 0.15)
		await animation_player.animation_finished
		is_attacking = false

func dash():
	if knight_stamina >= 16:
		is_dashing = true
		effect_knight.disabled = true
		weapon.disabled = true
		set_collision_layer_value(3,false)
		set_collision_mask_value(3,false)
		stamina_drain(16)
		var dash_direction = 1 if not pivot_point.scale.x == -1 else -1
		velocity.x = dash_direction * dash_speed
		print(velocity.x)
		_play_if_new("dash")
		await  animation_player.animation_finished
		set_collision_layer_value(3,true)
		set_collision_mask_value(3,true)
		effect_knight.disabled = false
		weapon.disabled = false
		is_dashing = false

func update_animations():
	
	var direction = Input.get_axis("move_left","move_right")
	
	if is_on_floor():
		if direction != 0:
			pivot_point.scale.x = 1 if direction > 0 else -1
		#elif abs(velocity.x) > 1:
			#pivot_point.scale.x =1 if velocity.x > 0 else -1
	if not is_on_floor() and not wall_check_1.is_colliding():
		pivot_point.scale.x =1 if velocity.x > 0 else -1
	

	
	if is_dashing: 
		return
	
	if is_on_floor():
		if abs(velocity.x) > 5:
			_play_if_new("running")
		else:
			_play_if_new("idle")
	else:
		if velocity.y > 0:
			_play_if_new("fall")
		elif velocity.y < 0:
			_play_if_new("jump")

	
	if not is_on_floor() and wall_check_1.is_colliding() :
		_play_if_new("wall slide")
	
	if is_hurt:
		return
	



func _play_if_new(anim_name: String):
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

func _screen_shake(intensity: float, duration: float):
	var shake_timer = duration
	var initial_offset = camera_2d.offset
	while shake_timer > 0:
		var offset_x = randf_range(-intensity, intensity)
		var offset_y = randf_range(-intensity, intensity)
		
		camera_2d.offset = initial_offset + Vector2(offset_x, offset_y)
		
		shake_timer -= get_process_delta_time()
		intensity = lerp(intensity, 0.0, 0.1)
		await get_tree().process_frame
	camera_2d.offset = initial_offset


func _on_knight_weapons_area_entered(area: Area2D) -> void:
	if area.name == "psrooma body":
		if animation_player.current_animation == "attack 1" : 
			Global.player_attack.emit(15)
			print("15 aua")
		elif animation_player.current_animation == "attack combo" : 
			Global.player_attack.emit(25)
			print("25 aua")
		elif animation_player.current_animation == "run attack" : 
			Global.player_attack.emit(20)
			print("20 aua")
