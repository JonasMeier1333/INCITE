extends Control

@onready var total_score_anzeige: Label = $VBoxContainer/TotalScoreAnzeige
@onready var deaths: Label = $VBoxContainer/Deaths
@onready var coin_death_trade: Button = $VBoxContainer/CoinDeathTrade



func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level1.tscn")
	

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")
	
	
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_coin_death_trade_pressed() -> void:
	if Global.total_score>=3 and Global.deaths>0:
		Global.total_score -=3
		Global.deaths -=1




func _process(delta: float)  -> void:
	
	total_score_anzeige.text = ("Total Score: ") + str(Global.total_score)
	deaths.text = ("Deaths: ") + str(Global.deaths)
	coin_death_trade.disabled= (Global.total_score<3 or Global.deaths==0)
	
	
	


	
	
