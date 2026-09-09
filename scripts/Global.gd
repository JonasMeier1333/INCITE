extends Node

var total_score = 0
var deaths = 0
var aktueller_pfad = ""

var timer_start = false 
var spielende = false
var from_mm = false
var startposition_x = 0.0
var startposition_y = 0.0
signal health_changed

signal player_attacked(damage)
signal player_take_damage(damage)
signal player_attack(attack_damage)
signal player_is_dead(player_just_died)
signal bonfire_regen(regen)

signal load_position()

var max_health = 30

var health = 30:
	set(value):
		health = clamp(value, 0, max_health)
		health_changed.emit()
