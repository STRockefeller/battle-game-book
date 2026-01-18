# BattleManager.gd
# 基礎對戰管理器 - 支援單機和多人模式
# 單機模式：直接使用此類加上 AI
# 多人模式：將此類作為基類，由子類實現伺服器/客戶端邏輯
extends Node
class_name BattleManager

const MODE_SINGLEPLAYER = "singleplayer"
const MODE_SERVER = "server"
const MODE_CLIENT = "client"

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

# ==================== 對戰模式 ====================

var battle_mode: String = MODE_SINGLEPLAYER
var state: Variant  # BattleState，使用 Variant 避免前置聲明問題

# ==================== 角色和狀態 ====================

var player1: Character
var player2: Character
var characters: Array[Character] = []

# 效果系統（用於被動特質等）
var effect_manager

# AI 行為
var player1_ai: AIBehavior
var player2_ai: AIBehavior

# 當前回合的選擇
var pending_selections: Dictionary[Character, Action] = {}
var selections_completed: int = 0

# 當前距離（用於距離相關的計算）
var current_distance: String = "mid"

# 是否等待玩家輸入
var waiting_for_input: bool = false

# ==================== 初始化 ====================

func _ready():
	# 檢查是否有來自 CharacterSelection 的配置
	if BattleConfig.player_character and BattleConfig.enemy_character:
		player1 = BattleConfig.player_character
		player2 = BattleConfig.enemy_character
		BattleConfig.clear_config()
	else:
		# 後備方案：使用預設角色
		if not player1:
			var hero_template = load("res://resources/characters/Elise.tres")
			if hero_template:
				player1 = hero_template.duplicate()
		
		if not player2:
			var hero_template = load("res://resources/characters/Elise.tres")
			if hero_template:
				player2 = hero_template.duplicate()
	
	characters = [player1, player2]

	# 設置效果系統並套用被動特質
	effect_manager = EffectManager.new()
	var p_traits = BattleConfig.get_player_passive_traits()
	var e_traits = BattleConfig.get_enemy_passive_traits()
	for tid in p_traits:
		var pasive_trait = PassiveTraitLibrary.get_trait_by_id(tid)
		if pasive_trait:
			var mod = pasive_trait.to_modifier()
			effect_manager.add_modifier(mod)
	for tid in e_traits:
		var trait_e = PassiveTraitLibrary.get_trait_by_id(tid)
		if trait_e:
			var mod_e = trait_e.to_modifier()
			effect_manager.add_modifier(mod_e)
	
	# 初始化戰鬥狀態
	var BattleStateClass = load("res://scripts/BattleState.gd")
	state = BattleStateClass.new(
		player1.max_hp, player1.max_mp, player1.max_stamina,
		player2.max_hp, player2.max_mp, player2.max_stamina
	)
	
	# 驗證初始化
	print("[BattleManager] 戰鬥初始化完成 (模式: %s)" % battle_mode)
	print("  Player1: %s - HP=%d, MP=%d, Stamina=%d" % [player1.get_display_name(), get_current_hp(player1), get_current_mp(player1), get_current_stamina(player1)])
	print("  Player2: %s - HP=%d, MP=%d, Stamina=%d" % [player2.get_display_name(), get_current_hp(player2), get_current_mp(player2), get_current_stamina(player2)])
	
	# 設置 StatusEffectHandlers 的 battle_manager 引用
	StatusEffectHandlers.battle_manager = self
	
	# 設置 AI（player2 是 AI，單機模式下）
	if battle_mode == MODE_SINGLEPLAYER:
		if not player2_ai:
			var ai_type = BattleConfig.get_enemy_ai_behavior()
			player2_ai = AIFactory.create_ai(ai_type)
			add_child(player2_ai)
			print("[BattleManager] 已創建 AI: %s" % ai_type)

## 開始戰鬥
func start_battle():
	state.turn = 0
	begin_round()

## 開始新的回合
func begin_round():
	if state.turn >= state.max_turns:
		# 達到最大回合數 - 平局
		battle_ended.emit(null)
		return
	
	state.turn += 1
	print("[BattleManager] === 第 %d 回合開始 ===" % state.turn)
	
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
	
	# AI 立即做決策（單機模式）
	if battle_mode == MODE_SINGLEPLAYER:
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
func _calculate_execution_order() -> Array[Dictionary]:
	var order: Array[Dictionary] = []
	
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
	order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["speed"] != b["speed"]:
			return a["speed"] > b["speed"]
		return a["priority"] > b["priority"]
	)
	
	return order

## 執行單個動作 - 核心邏輯，被子類重寫以支援網路同步
func _execute_single_action(user: Character, target: Character, action: Action):
	var result = {
		"hit": false,
		"damage": 0,
		"actual_damage": 0,
		"cost_mp": action.cost_mp,
		"cost_stamina": action.cost_stamina,
		"status_applied": null,
		"stance_changed": false
	}
	
	print("[_execute_single_action] %s 使用 %s | 檢查資源成本" % [user.get_display_name(), action.name])
	
	# 1. 檢查冷卻
	var cooldowns = _get_player_cooldowns(user)
	if cooldowns.has(action.id) and cooldowns[action.id] > 0:
		print("  [冷卻中] 冷卻剩餘: %d" % cooldowns[action.id])
		action_executed.emit(user, target, action, result)
		return
	
	# 2. 檢查資源成本（應用被動效果的消耗減免）
	var cost_result = calculate_action_cost(user, target, action)
	var cost_stamina = cost_result["stamina"]
	var cost_mp = cost_result["mp"]
	var current_stamina = get_current_stamina(user)
	var current_mp = get_current_mp(user)
	
	print("  [資源檢查] Stamina: %d/%d (成本%d), MP: %d/%d (成本%d)" % [current_stamina, user.max_stamina, cost_stamina, current_mp, user.max_mp, cost_mp])
	
	if current_stamina < cost_stamina or current_mp < cost_mp:
		print("  [資源不足] 動作執行失敗 - 返回")
		action_executed.emit(user, target, action, result)
		return
	
	# 3. 扣除資源
	var new_stamina = current_stamina - cost_stamina
	var new_mp = current_mp - cost_mp
	set_current_stamina(user, new_stamina)
	set_current_mp(user, new_mp)
	print("  [資源扣除] Stamina: %d→%d, MP: %d→%d" % [current_stamina, get_current_stamina(user), current_mp, get_current_mp(user)])
	
	# 4. 計算命中
	# 格擋動作（包含 "guard" 標籤）自動成功
	if "guard" in action.tags:
		result["hit"] = true
		print("  [格擋] 自動成功")
	else:
		var hit_result = calculate_hit_chance(user, target, action)
		result["hit"] = hit_result["hit"]
		print("  [命中判定] %s → %s: 基礎=%s%%, 命中加成=%d, 閃避=%d, 最終=%s%%, 判定=%s" % [
			user.get_display_name(), 
			target.get_display_name(), 
			hit_result["base_accuracy"],
			hit_result["accuracy_bonus"],
			hit_result["evasion_bonus"],
			hit_result["final_accuracy"],
			result["hit"]
		])
	
	if result["hit"]:
		# 5. 計算傷害（應用被動特質）
		result["damage"] = action.damage
		result["actual_damage"] = calculate_final_damage(user, target, action, action.damage)
		
		print("  [傷害計算] 基礎=%d, 最終=%d" % [action.damage, result["actual_damage"]])
		
		if action.damage > 0:
			# 計算爆擊（應用被動）
			var crit_result = calculate_critical_result(user, target, action, result["actual_damage"])
			result["is_critical"] = crit_result["is_critical"]
			result["actual_damage"] = crit_result["damage"]
			
			if result["is_critical"]:
				print("  [爆擊!] 爆擊率=%.1f%%, 倍率=%.2f, 傷害=%d → %d" % [
					crit_result["crit_rate"],
					crit_result["crit_multiplier"],
					action.damage,
					result["actual_damage"]
				])
			
			# 應用傷害
			var current_hp = get_current_hp(target)
			set_current_hp(target, current_hp - result["actual_damage"])
		
		# 6. 應用狀態效果
		if action.effects_on_hit.size() > 0:
			for effect_id in action.effects_on_hit:
				var effect_resource = load("res://resources/statuses/%s.tres" % effect_id.capitalize())
				if effect_resource:
					target.apply_effect(effect_resource)
					result["status_applied"] = effect_id
					print("  [狀態效果] 對 %s 施加了 %s" % [target.get_display_name(), effect_id])
				else:
					print("  [警告] 無法加載狀態效果: %s" % effect_id)
		
		# 7. 改變姿態（目標）
		if action.target_stance_change_enabled:
			var stance_type: Stance.Type = action.target_stance_change_to
			target.change_stance(stance_type, -1)
			result["stance_changed"] = true
			_update_player_stance(target, stance_type)
			print("  [姿態變更] %s 變更為 %s" % [target.get_display_name(), Stance.get_stance_name(stance_type)])
	
	# 8. 使用者姿態變更（用於起身等自身動作）
	if action.user_stance_change_enabled:
		var stance_type: Stance.Type = action.user_stance_change_to
		user.change_stance(stance_type, -1)
		result["stance_changed"] = true
		_update_player_stance(user, stance_type)
		print("  [姿態變更] %s 變更為 %s" % [user.get_display_name(), Stance.get_stance_name(stance_type)])
	
	# 9. 特殊動作效果（如恢復體力）
	if "rest" in action.tags:
		var stamina_restore = 20
		set_current_stamina(user, get_current_stamina(user) + stamina_restore)
		print("  [恢復體力] %s 恢復了 %d 體力" % [user.get_display_name(), stamina_restore])
	
	# 10. 設置冷卻
	if action.cooldown > 0:
		var updated_cooldowns = _get_player_cooldowns(user).duplicate()
		updated_cooldowns[action.id] = action.cooldown
		_set_player_cooldowns(user, updated_cooldowns)
	
	# 發送信號
	action_executed.emit(user, target, action, result)

## 回合結束階段
func _turn_end_phase():
	# 觸發回合結束效果
	for character in characters:
		if character:
			character.on_turn_end()
	
	# 減少所有冷卻
	var p1_cooldowns = _get_player_cooldowns(player1).duplicate()
	var p2_cooldowns = _get_player_cooldowns(player2).duplicate()
	
	# 減少 P1 冷卻
	var p1_to_remove = []
	for action_id in p1_cooldowns:
		p1_cooldowns[action_id] -= 1
		if p1_cooldowns[action_id] <= 0:
			p1_to_remove.append(action_id)
	for action_id in p1_to_remove:
		p1_cooldowns.erase(action_id)
	
	# 減少 P2 冷卻
	var p2_to_remove = []
	for action_id in p2_cooldowns:
		p2_cooldowns[action_id] -= 1
		if p2_cooldowns[action_id] <= 0:
			p2_to_remove.append(action_id)
	for action_id in p2_to_remove:
		p2_cooldowns.erase(action_id)
	
	_set_player_cooldowns(player1, p1_cooldowns)
	_set_player_cooldowns(player2, p2_cooldowns)
	
	turn_ended.emit()
	
	# 檢查戰鬥是否結束
	if _check_battle_end():
		return
	
	# 開始下一回合
	await get_tree().create_timer(0.5).timeout
	begin_round()

## 檢查戰鬥是否結束
func _check_battle_end() -> bool:
	if get_current_hp(player1) <= 0:
		battle_ended.emit(player2)
		return true
	if get_current_hp(player2) <= 0:
		battle_ended.emit(player1)
		return true
	return false

## 獲取角色的可用動作列表
func _get_available_actions(character: Character) -> Array[Action]:
	var available: Array[Action] = []
	var current_stance = character.stance_manager.get_current_stance_type()
	
	# 如果角色處於倒地狀態，只能使用起身動作
	if current_stance == Stance.Type.KNOCKED_DOWN:
		for action in character.available_actions:
			if action.is_usable_in(current_stance):
				available.append(action)
		return available
	
	# 正常情況下檢查姿態限制和其他條件
	for action in character.available_actions:
		# 檢查動作是否可在當前姿態執行
		if not action.is_usable_in(current_stance):
			continue
		available.append(action)
	
	return available

## 取得動作狀態（UI 用來顯示可用性）
func get_action_state(character: Character, action: Action) -> Dictionary:
	var cooldowns = _get_player_cooldowns(character)
	var cooldown_remaining: int = 0
	if cooldowns.has(action.id):
		cooldown_remaining = int(cooldowns[action.id])

	var cost_stamina: int = max(action.cost_stamina, 0)
	var cost_mp: int = max(action.cost_mp, 0)
	var current_stamina: int = get_current_stamina(character)
	var current_mp: int = get_current_mp(character)
	var insufficient: bool = current_stamina < cost_stamina or current_mp < cost_mp

	return {
		"cooldown": cooldown_remaining,
		"insufficient": insufficient,
		"disabled": cooldown_remaining > 0 or insufficient,
		"cost_stamina": cost_stamina,
		"cost_mp": cost_mp,
		"current_stamina": current_stamina,
		"current_mp": current_mp
	}

## 命中判定
func _roll_hit(action_accuracy: float, accuracy_bonus: int) -> bool:
	return BattleLogic.calculate_hit_static(action_accuracy, accuracy_bonus)

# ==================== 戰鬥計算方法（集中管理所有修正因素）====================

## 計算動作的實際消耗（應用所有修正）
func calculate_action_cost(user: Character, target: Character, action: Action) -> Dictionary:
	var base_stamina = max(action.cost_stamina, 0)
	var base_mp = max(action.cost_mp, 0)
	
	# 應用消耗減免修正
	var stamina_reduction = 0.0
	var mp_reduction = 0.0
	
	if effect_manager:
		stamina_reduction = effect_manager.apply_effects(
			"stamina_cost_reduction", 0.0, user, target, action, state.turn, action.tags
		)
		mp_reduction = effect_manager.apply_effects(
			"mp_cost_reduction", 0.0, user, target, action, state.turn, action.tags
		)
	
	return {
		"stamina": int(max(0.0, round(float(base_stamina) * (1.0 - stamina_reduction)))),
		"mp": int(max(0.0, round(float(base_mp) * (1.0 - mp_reduction))))
	}

## 計算最終傷害（應用所有修正）
func calculate_final_damage(attacker: Character, defender: Character, action: Action, base_damage: int) -> int:
	if base_damage <= 0:
		return 0
	
	var damage_bonus = 0.0
	var defense_reduction = 0.0
	
	if effect_manager:
		# 攻擊方的傷害加成
		damage_bonus = effect_manager.apply_effects(
			"damage_bonus", 0.0, attacker, defender, action, state.turn, action.tags
		)
		# 防守方的減傷
		defense_reduction = effect_manager.apply_effects(
			"damage_reduction", 0.0, defender, attacker, action, state.turn, action.tags
		)
	
	# 使用 BattleLogic 計算最終傷害
	var final_damage = BattleLogic.calculate_damage_result(
		base_damage, 
		damage_bonus * 100.0, 
		defense_reduction * 100.0
	)
	
	return final_damage

## 計算爆擊結果（應用所有修正）
func calculate_critical_result(attacker: Character, defender: Character, action: Action, base_damage: int) -> Dictionary:
	var crit_rate_bonus = 0.0
	var crit_multiplier = 1.5  # 預設爆擊倍率
	
	if effect_manager:
		# 爆擊率加成
		crit_rate_bonus = effect_manager.apply_effects(
			"critical_rate", 0.0, attacker, defender, action, state.turn, action.tags
		)
		# 爆擊傷害倍率
		crit_multiplier = effect_manager.apply_effects(
			"critical_damage_multiplier", 1.5, attacker, defender, action, state.turn, action.tags
		)
	
	var final_crit_rate = action.critical_rate + crit_rate_bonus * 100.0
	var is_critical = randf() * 100 < final_crit_rate
	
	var final_damage = base_damage
	if is_critical:
		final_damage = BattleLogic.calculate_critical_damage(base_damage, crit_multiplier)
	
	return {
		"is_critical": is_critical,
		"crit_rate": final_crit_rate,
		"crit_multiplier": crit_multiplier,
		"damage": final_damage
	}

## 計算命中率（應用所有修正）
func calculate_hit_chance(attacker: Character, defender: Character, action: Action) -> Dictionary:
	var base_accuracy = action.get_accuracy_at_range(current_distance)
	var accuracy_bonus = 0
	var evasion_bonus = 0
	
	# 可以從角色或效果系統獲取修正
	if attacker:
		accuracy_bonus = attacker.get_accuracy_bonus()
	
	if defender:
		evasion_bonus = defender.get_evasion_bonus()
	
	# 將來可以在這裡添加更多修正因素
	# 例如：地形、天氣、狀態效果等
	
	var final_accuracy = base_accuracy + accuracy_bonus - evasion_bonus
	var did_hit = _roll_hit(final_accuracy, 0)
	
	return {
		"base_accuracy": base_accuracy,
		"accuracy_bonus": accuracy_bonus,
		"evasion_bonus": evasion_bonus,
		"final_accuracy": final_accuracy,
		"hit": did_hit
	}

# ==================== 狀態管理方法 ====================

## 獲取角色當前 HP
func get_current_hp(character: Character) -> int:
	if character == player1:
		return state.p1_current_hp
	else:
		return state.p2_current_hp

## 設置角色當前 HP
func set_current_hp(character: Character, value: int) -> void:
	var max_hp = character.max_hp
	var clamped = clamp(value, 0, max_hp)
	if character == player1:
		state.p1_current_hp = clamped
	else:
		state.p2_current_hp = clamped

## 獲取角色當前 MP
func get_current_mp(character: Character) -> int:
	if character == player1:
		return state.p1_current_mp
	else:
		return state.p2_current_mp

## 設置角色當前 MP
func set_current_mp(character: Character, value: int) -> void:
	var max_mp = character.max_mp
	var clamped = clamp(value, 0, max_mp)
	if character == player1:
		state.p1_current_mp = clamped
	else:
		state.p2_current_mp = clamped

## 獲取角色當前 Stamina
func get_current_stamina(character: Character) -> int:
	if character == player1:
		return state.p1_current_stamina
	else:
		return state.p2_current_stamina

## 設置角色當前 Stamina
func set_current_stamina(character: Character, value: int) -> void:
	var max_stamina = character.max_stamina
	var clamped = clamp(value, 0, max_stamina)
	if character == player1:
		state.p1_current_stamina = clamped
	else:
		state.p2_current_stamina = clamped

# ==================== 輔助方法 ====================

## 將字符串轉換為姿態類型
func _parse_stance_type(stance_str: String) -> Variant:
	match stance_str.to_lower():
		"standing":
			return Stance.Type.STANDING
		"knocked_down", "knockdown":
			return Stance.Type.KNOCKED_DOWN
		"airborne":
			return Stance.Type.AIRBORNE
		"guarding", "guard":
			return Stance.Type.GUARDING
		_:
			print("  [警告] 無法解析姿態類型: %s" % stance_str)
			return null

## 將 Character 轉換為玩家 ID（1 或 2）
func get_player_id(character: Character) -> int:
	return 1 if character == player1 else 2

## 根據玩家 ID 獲取 Character
func get_character_by_id(player_id: int) -> Character:
	return player1 if player_id == 1 else player2

# ==================== 冷卻管理 ====================

## 獲取玩家冷卻字典
func _get_player_cooldowns(character: Character) -> Dictionary:
	if character == player1:
		return state.p1_cooldowns
	else:
		return state.p2_cooldowns

## 設置玩家冷卻字典
func _set_player_cooldowns(character: Character, cooldowns: Dictionary) -> void:
	if character == player1:
		state.set_p1_cooldowns(cooldowns)
	else:
		state.set_p2_cooldowns(cooldowns)

## 更新玩家姿態狀態
func _update_player_stance(character: Character, stance_type: Stance.Type) -> void:
	if character == player1:
		state.p1_stance = stance_type
	else:
		state.p2_stance = stance_type
