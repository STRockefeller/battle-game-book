# BattleConfig.gd
# 自動加載的全局配置管理器
extends Node

# 當前戰鬥配置
var player_character: Character
var enemy_character: Character
var enemy_ai_behavior: String = "random"
var player_passive_traits: Array[String] = []
var enemy_passive_traits: Array[String] = []

func set_battle_config(player: Character, enemy: Character, ai_behavior: String, p_traits: Array[String] = [], e_traits: Array[String] = []) -> void:
	player_character = player
	enemy_character = enemy
	enemy_ai_behavior = ai_behavior
	player_passive_traits = p_traits
	enemy_passive_traits = e_traits

func get_player_character() -> Character:
	return player_character

func get_enemy_character() -> Character:
	return enemy_character

func get_enemy_ai_behavior() -> String:
	return enemy_ai_behavior

func get_player_passive_traits() -> Array[String]:
	return player_passive_traits

func get_enemy_passive_traits() -> Array[String]:
	return enemy_passive_traits

func clear_config() -> void:
	player_character = null
	enemy_character = null
	enemy_ai_behavior = "random"
	player_passive_traits = []
	enemy_passive_traits = []
