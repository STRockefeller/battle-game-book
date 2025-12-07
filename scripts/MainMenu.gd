# MainMenu.gd
extends Control

func _ready():
	pass

func _on_new_game_pressed():
	print("開始遊戲 - 功能待實現")

func _on_test_battle_pressed():
	# 加載並切換到戰鬥場景
	get_tree().change_scene_to_file("res://scenes/BattleUI.tscn")

func _on_settings_pressed():
	print("設置 - 功能待實現")

func _on_credits_pressed():
	print("製作人員 - 功能待實現")

func _on_exit_pressed():
	# 退出遊戲
	get_tree().quit()
