# BattleManagerEffectsIntegration.gd
# 示例代碼 - 展示如何在 BattleManager 中集成效果系統
# 這不是完整的 BattleManager，僅顯示相關的集成點

class_name BattleManagerEffectsIntegration
extends Node

## 效果管理器
var modifier_manager: StatModifierManager

## 活躍的神恩任務
var active_divine_tasks: Array[DivineBlessingTask] = []

## 玩家選擇的被動特質
var selected_passive_traits: Array[String] = []

## 當前戰鬥狀態
var battle_state: BattleState

## 戰鬥雙方
var player_character: Character
var opponent_character: Character

# ==================== 初始化 ====================

## 初始化效果系統
func initialize_effects(player: Character, opponent: Character, 
                       traits: Array[String], 
                       divine_difficulty: int = 1) -> void:
	player_character = player
	opponent_character = opponent
	selected_passive_traits = traits
	
	# 創建效果管理器
	modifier_manager = StatModifierManager.new()
	
	# 添加被動特質
	for trait_id in selected_passive_traits:
		var passive_trait = PassiveTraitLibrary.get_trait_by_id(trait_id)
		if passive_trait:
			var group = passive_trait.to_group()
			modifier_manager.add_group(group)
			print("Added passive trait: %s" % passive_trait.name)
	
	# 初始化神恩任務
	_initialize_divine_tasks(divine_difficulty)

## 初始化神恩任務
func _initialize_divine_tasks(difficulty: int) -> void:
	var deities = [
		"god_of_war",
		"goddess_of_wisdom",
		"god_of_commerce",
		"goddess_of_life",
		"god_of_deceit",
		"god_of_balance"
	]
	
	for deity_id in deities:
		var task = DivineBlessingTaskLibrary.create_task(deity_id, difficulty)
		active_divine_tasks.append(task)
		print("Initialized divine task: %s (difficulty: %d)" % [deity_id, difficulty])

# ==================== 回合管理 ====================

## 回合開始
func start_turn(_turn: int) -> void:
	# 更新所有效果修正器（減少持續時間，移除過期效果）
	modifier_manager.tick()
	
	# 檢查神恩任務完成情況
	var completed_tasks = []
	for task in active_divine_tasks:
		if task.is_completed():
			var blessing = task.to_group()
			modifier_manager.add_group(blessing)
			completed_tasks.append(task)
			print("Divine task completed: %s" % task.name)
	
	# 移除已完成的任務
	for task in completed_tasks:
		active_divine_tasks.erase(task)

## 回合結束
func end_turn(_turn: int) -> void:
	pass

# ==================== 傷害計算 ====================

## 計算傷害（應用所有效果修正）
func calculate_final_damage(attacker: Character, defender: Character, 
                            action: Action, base_damage: int) -> int:
	# 基礎傷害已由 BattleLogic 計算
	var damage = float(base_damage)
	
	# 應用傷害加成效果
	damage = modifier_manager.apply_modifiers(
		"damage_bonus",
		damage,
		attacker,
		defender,
		action,
		battle_state.current_turn,
		action.tags
	)
	
	# 應用防禦減傷效果
	damage = damage * (1.0 - modifier_manager.apply_modifiers(
		"defense_bonus",
		0.0,
		defender,
		attacker,
		null,
		battle_state.current_turn,
		[]
	))
	
	return int(max(1, damage))  # 最少 1 傷害

## 計算最終治療量
func calculate_final_healing(healer: Character, target: Character,
                            action: Action, base_healing: int) -> int:
	var healing = float(base_healing)
	
	# 應用治療加成效果
	healing = modifier_manager.apply_modifiers(
		"hp_recovery",
		healing,
		healer,
		target,
		action,
		battle_state.current_turn,
		action.tags
	)
	
	return int(healing)

# ==================== 資源管理 ====================

## 計算體力消耗
func calculate_stamina_cost(character: Character, action: Action) -> int:
	var base_cost = action.cost_stamina
	
	# 應用體力消耗減少效果
	var modified_cost = modifier_manager.apply_modifiers(
		"stamina_cost_reduction",
		float(base_cost),
		character,
		opponent_character,
		action,
		battle_state.current_turn,
		action.tags
	)
	
	return int(max(0, modified_cost))

## 計算最終 MP 消耗
func calculate_mp_cost(character: Character, action: Action) -> int:
	var base_cost = action.cost_mp
	
	var modified_cost = modifier_manager.apply_modifiers(
		"mp_cost_reduction",
		float(base_cost),
		character,
		opponent_character,
		action,
		battle_state.current_turn,
		action.tags
	)
	
	return int(max(0, modified_cost))

# ==================== 行動執行 ====================

## 行動被執行時更新神恩任務
func on_action_executed(actor: Character, action: Action) -> void:
	# 準備進度數據
	var progress_data = {
		"action_id": action.id,
		"action_tags": action.tags,
		"actor_hp_percent": float(actor.get_current_hp()) / float(actor.max_hp),
		"opponent_hp_percent": float(opponent_character.get_current_hp()) / float(opponent_character.max_hp),
		"turn": battle_state.current_turn,
	}
	
	# 更新所有活躍任務
	for task in active_divine_tasks:
		task.update_progress(progress_data)

# ==================== 狀態查詢 ====================

## 檢查是否有特定來源的活躍效果
func has_active_effect_from_source(source: String) -> bool:
	return modifier_manager.has_modifier_from_source(source)

## 獲取所有活躍的傷害加成效果
func get_damage_modifiers(attacker: Character, defender: Character, 
                         action: Action) -> Array[ModifierGroup]:
	return modifier_manager.get_active_modifiers(
		"damage_bonus",
		attacker,
		defender,
		action,
		battle_state.current_turn
	)

## 獲取調試信息
func get_effects_debug_info() -> String:
	var info = "=== EFFECT MANAGER DEBUG ===\n"
	info += modifier_manager.get_debug_info()
	info += "\n=== ACTIVE DIVINE TASKS ===\n"
	for task in active_divine_tasks:
		info += "- %s (deity: %s, completed: %s)\n" % [
			task.name,
			task.deity_id,
			task.is_completed()
		]
	return info

## 打印效果調試信息
func print_effects_debug() -> void:
	print(get_effects_debug_info())

# ==================== 清理 ====================

## 戰鬥結束時清理
func cleanup() -> void:
	modifier_manager.clear()
	active_divine_tasks.clear()

# ==================== 示例使用 ====================

## 示例：創建一個簡單的戰鬥場景
func example_battle_setup() -> void:
	# 創建兩個角色
	var player = Character.new()
	player.name = "Hero"
	player.max_hp = 100
	
	var opponent = Character.new()
	opponent.name = "Enemy"
	opponent.max_hp = 100
	
	# 初始化效果系統，玩家選擇 2 個被動特質和困難神恩
	initialize_effects(player, opponent, ["brute_force", "nimble_steps"], 2)
	
	# 模擬第 1 回合
	print("\n=== Turn 1 ===")
	start_turn(1)
	
	# 模擬玩家執行攻擊
	var basic_attack = Action.new()
	basic_attack.name = "Basic Attack"
	basic_attack.tags = ["physical", "attack"]
	basic_attack.cost_stamina = 10
	
	on_action_executed(player, basic_attack)
	
	# 計算傷害
	var base_damage = 30
	var final_damage = calculate_final_damage(player, opponent, basic_attack, base_damage)
	print("Base damage: %d, Final damage: %d" % [base_damage, final_damage])
	
	# 打印調試信息
	print_effects_debug()
	
	# 模擬第 2 回合
	print("\n=== Turn 2 ===")
	end_turn(1)
	start_turn(2)
	
	on_action_executed(player, basic_attack)
	final_damage = calculate_final_damage(player, opponent, basic_attack, base_damage)
	print("Base damage: %d, Final damage: %d" % [base_damage, final_damage])
	
	# 清理
	cleanup()
