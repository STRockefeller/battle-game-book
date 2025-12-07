# BattleConfig.gd
# 自動加載的全局配置管理器
extends Node

# 當前戰鬥配置
var player_character: Character
var enemy_character: Character
var enemy_ai_behavior: String = "random"

func set_battle_config(player: Character, enemy: Character, ai_behavior: String) -> void:
	player_character = player
	enemy_character = enemy
	enemy_ai_behavior = ai_behavior

func get_player_character() -> Character:
	return player_character

func get_enemy_character() -> Character:
	return enemy_character

func get_enemy_ai_behavior() -> String:
	return enemy_ai_behavior

func clear_config() -> void:
	player_character = null
	enemy_character = null
	enemy_ai_behavior = "random"
