# BattleManager.gd
# 完整的對戰系統 - 同時行動制、回合循環、AI 支持
extends Node
class_name BattleManager

# ==================== 信號定義 ====================

## 回合開始時發送 - 需要玩家和 AI 選擇動作
signal turn_start_selection(player1: Character, player2: Character)

## 當所有選擇都完成時發送 - 即將開始應用結果
signal all_actions_selected()

## 動作應用時發送 - 顯示單個行動的結果
signal action_executed(user: Character, target: Character, action: Action, result: Dictionary)

## 回合結束時發送
signal turn_ended()

## 戰鬥結束時發送
signal battle_ended(winner: Character)

# ==================== 角色和狀態 ====================

var player1: Character
var player2: Character
var characters: Array[Character] = []

# AI 行為
var player1_ai: AIBehavior
var player2_ai: AIBehavior

# 冷卻時間追蹤
var action_cooldowns: Dictionary = {}  # character -> {action_id -> remaining_cooldown}

# 當前回合的選擇
var pending_selections: Dictionary = {}  # character -> Action
var selections_completed: int = 0

# 當前距離（用於距離相關的計算）
var current_distance: String = "mid"

# 是否等待玩家輸入
var waiting_for_input: bool = false
var current_turn: int = 0
var max_turns: int = 100  # 防止無限迴圈

# ==================== 初始化 ====================

func _ready():
	# 初始化玩家（複製資源以避免共享狀態）
	if not player1:
		var hero_template = load("res://resources/characters/Elise.tres")
		if hero_template:
			player1 = hero_template.duplicate()
	
	if not player2:
		var hero_template = load("res://resources/characters/Elise.tres")
		if hero_template:
			player2 = hero_template.duplicate()
	
	characters = [player1, player2]
	
	# 初始化冷卻追蹤
	action_cooldowns[player1] = {}
	action_cooldowns[player2] = {}
	
	# 設置 AI（player2 是 AI）
	if not player2_ai:
		player2_ai = RandomAIBehavior.new()
		add_child(player2_ai)

## 開始戰鬥
func start_battle():
	current_turn = 0
	max_turns = 100
	begin_round()

## 開始新的回合
func begin_round():
	if current_turn >= max_turns:
		# 達到最大回合數 - 平局
		battle_ended.emit(null)
		return
	
	current_turn += 1
	
	# ========== 第 1 階段：回合開始 ==========
	_turn_start_phase()
	
	# ========== 第 2 階段：行動選擇 ==========
	_action_selection_phase()

## 回合開始階段 - 觸發回合開始效果
func _turn_start_phase():
	for character in characters:
		if character:
			character.on_turn_start()

## 行動選擇階段 - 收集玩家和 AI 的選擇
func _action_selection_phase():
	pending_selections.clear()
	selections_completed = 0
	waiting_for_input = true
	
	# 發送信號，請求選擇
	turn_start_selection.emit(player1, player2)
	
	# AI 立即做決策
	_ai_select_action()

## 玩家選擇動作
func player_select_action(action: Action):
	if not waiting_for_input:
		return
	
	# 檢查是否是玩家 1 的有效動作
	var available = _get_available_actions(player1)
	if action not in available:
		return
	
	pending_selections[player1] = action
	selections_completed += 1
	
	if selections_completed >= 2:
		# 所有選擇都完成了
		_all_selections_complete()

## AI 選擇動作
func _ai_select_action():
	var available = _get_available_actions(player2)
	var chosen_action = player2_ai.choose_action(player2, available, player1, self)
	
	if chosen_action:
		pending_selections[player2] = chosen_action
		selections_completed += 1
		
		if selections_completed >= 2:
			# 所有選擇都完成了
			_all_selections_complete()

## 所有選擇都完成 - 開始應用結果
func _all_selections_complete():
	waiting_for_input = false
	all_actions_selected.emit()
	
	# 讓 UI 有時間動畫顯示，然後執行動作
	await get_tree().create_timer(0.5).timeout
	_apply_actions_phase()

## 結果應用階段 - 按照優先度執行所有動作
func _apply_actions_phase():
	# 構建執行順序
	var execution_order = _calculate_execution_order()
	
	# 按順序執行動作
	for action_data in execution_order:
		var user = action_data["user"]
		var target = action_data["target"]
		var action = action_data["action"]
		
		_execute_single_action(user, target, action)
		
		# 檢查戰鬥是否已結束
		if _check_battle_end():
			return
		
		# 讓 UI 有時間顯示
		await get_tree().create_timer(0.3).timeout
	
	# ========== 第 4 階段：回合結束 ==========
	_turn_end_phase()

## 計算動作執行順序（根據敏捷和優先度）
func _calculate_execution_order() -> Array:
	var order: Array = []
	
	for user in pending_selections:
		var action = pending_selections[user]
		var target = player2 if user == player1 else player1
		var speed = user.get_effective_stat("agi")
		var priority = action.priority
		
		order.append({
			"user": user,
			"target": target,
			"action": action,
			"speed": speed,
			"priority": priority
		})
	
	# 按敏捷度和優先度排序（高敏捷和高優先度優先）
	order.sort_custom(func(a, b):
		if a["speed"] != b["speed"]:
			return a["speed"] > b["speed"]
		return a["priority"] > b["priority"]
	)
	
	return order

## 執行單個動作
func _execute_single_action(user: Character, target: Character, action: Action):
	var result = {
		"hit": false,
		"damage": 0,
		"actual_damage": 0,
		"mp_cost": action.cost_mp,
		"sta_cost": action.stamina_cost,
		"status_applied": null,
		"stance_changed": false
	}
	
	# 1. 檢查冷卻
	var cooldowns = action_cooldowns[user]
	if cooldowns.has(action.id):
		action_executed.emit(user, target, action, result)
		return
	
	# 2. 檢查資源成本
	var sta_cost = action.stamina_cost if action.stamina_cost > 0 else 0
	var mp_cost = action.cost_mp if action.cost_mp > 0 else 0
	
	if user.current_sta < sta_cost or user.current_mp < mp_cost:
		action_executed.emit(user, target, action, result)
		return
	
	# 3. 扣除資源
	user.current_sta -= sta_cost
	user.current_mp -= mp_cost
	
	# 4. 計算命中
	var accuracy = user.get_effective_stat("acc") + action.accuracy_modifier
	var evasion = target.get_effective_stat("eva")
	result["hit"] = _roll_hit(accuracy, evasion)
	
	if result["hit"]:
		# 5. 計算傷害
		var base_damage = user.get_effective_stat("atk") * action.damage_multiplier
		var target_def = target.get_effective_stat("def")
		result["damage"] = base_damage
		result["actual_damage"] = max(1, int(base_damage) - int(target_def))
		
		# 應用傷害
		target.take_damage(result["actual_damage"])
		
		# 6. 應用狀態效果
		if action.effects_on_hit.size() > 0:
			# TODO: 從 effects_on_hit ID 加載狀態效果資源並應用
			result["status_applied"] = action.effects_on_hit[0] if action.effects_on_hit.size() > 0 else null
		
		# 7. 改變姿態
		if action.target_stance_change_to != "":
			# TODO: 根據 target_stance_change_to 字符串確定姿態類型
			result["stance_changed"] = true
	
	# 8. 設置冷卻
	if action.cooldown > 0:
		cooldowns[action.id] = action.cooldown
	
	# 發送信號
	action_executed.emit(user, target, action, result)

## 回合結束階段
func _turn_end_phase():
	# 觸發回合結束效果
	for character in characters:
		if character:
			character.on_turn_end()
	
	# 減少所有冷卻
	for character in characters:
		if action_cooldowns.has(character):
			var cooldowns = action_cooldowns[character]
			var to_remove = []
			for action_id in cooldowns:
				cooldowns[action_id] -= 1
				if cooldowns[action_id] <= 0:
					to_remove.append(action_id)
			for action_id in to_remove:
				cooldowns.erase(action_id)
	
	turn_ended.emit()
	
	# 檢查戰鬥是否結束
	if _check_battle_end():
		return
	
	# 開始下一回合
	await get_tree().create_timer(0.5).timeout
	begin_round()

## 檢查戰鬥是否結束
func _check_battle_end() -> bool:
	if player1.current_hp <= 0:
		battle_ended.emit(player2)
		return true
	if player2.current_hp <= 0:
		battle_ended.emit(player1)
		return true
	return false

## 獲取角色的可用動作列表
func _get_available_actions(character: Character) -> Array:
	var available = []
	
	# 檢查姿態限制
	for action in character.available_actions:
		if character.can_perform_action(action.tags[0] if action.tags.size() > 0 else ""):
			available.append(action)
	
	return available

## 命中判定
func _roll_hit(accuracy: float, evasion: float) -> bool:
	var hit_chance = accuracy - evasion
	hit_chance = clamp(hit_chance, 5, 95)  # 保證至少有 5% 命中和迴避機率
	return randf() * 100 < hit_chance
