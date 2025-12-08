# BattleLogic.gd
# 無狀態的對戰核心邏輯 - 支援確定性計算和伺服器驗證
# 所有計算都是純函數，輸入相同則輸出必定相同，便於網路同步
class_name BattleLogic

# ==================== 命中判定 ====================

## 根據精準度和迴避計算命中
## 使用確定性的 RNG，便於伺服器驗證
func calculate_hit(accuracy: float, evasion: float, rng_seed: int = 0) -> bool:
	var rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	var hit_chance = accuracy - evasion
	hit_chance = clamp(hit_chance, 5, 95)  # 保證至少有 5% 命中和迴避機率
	return rng.randf() * 100 < hit_chance

## 靜態版本 - 不需要 Node 實例
static func calculate_hit_static(accuracy: float, evasion: float, rng_seed: int = 0) -> bool:
	var rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	var hit_chance = accuracy - evasion
	hit_chance = clamp(hit_chance, 5, 95)
	return rng.randf() * 100 < hit_chance

# ==================== 傷害計算 ====================

## 計算基礎傷害
static func calculate_base_damage(atk: int, damage_multiplier: float) -> float:
	return atk * damage_multiplier

## 計算實際傷害（包含防禦）
static func calculate_actual_damage(base_damage: float, defense: int) -> int:
	if base_damage <= 0.0:
		return 0
	return max(1, int(base_damage) - defense)

## 計算完整傷害結果
static func calculate_damage_result(atk: int, def: int, multiplier: float) -> int:
	var base = calculate_base_damage(atk, multiplier)
	return calculate_actual_damage(base, def)

# ==================== 資源成本檢查 ====================

## 檢查角色是否擁有足夠資源執行動作
static func can_afford_action(current_sta: int, current_mp: int, cost_sta: int, cost_mp: int) -> bool:
	return current_sta >= cost_sta and current_mp >= cost_mp

## 扣除資源
static func deduct_resources(current_sta: int, current_mp: int, cost_sta: int, cost_mp: int) -> Dictionary:
	return {
		"sta": clamp(current_sta - cost_sta, 0, current_sta),
		"mp": clamp(current_mp - cost_mp, 0, current_mp)
	}

# ==================== 執行順序計算 ====================

## 計算動作執行順序
## actions: Array[Dictionary] - 包含 "user", "action" 等資訊的陣列
## 返回按優先度排序的動作陣列
static func calculate_execution_order(actions: Array) -> Array:
	var order = actions.duplicate()
	
	# 按敏捷度和優先度排序（高敏捷和高優先度優先）
	order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_speed = a.get("speed", 0)
		var b_speed = b.get("speed", 0)
		var a_priority = a.get("priority", 0)
		var b_priority = b.get("priority", 0)
		
		if a_speed != b_speed:
			return a_speed > b_speed
		return a_priority > b_priority
	)
	
	return order

# ==================== 冷卻計算 ====================

## 檢查動作是否在冷卻中
static func is_action_on_cooldown(cooldowns: Dictionary, action_id: String) -> bool:
	return cooldowns.has(action_id) and cooldowns[action_id] > 0

## 減少所有冷卻時間
static func decrease_cooldowns(cooldowns: Dictionary) -> Dictionary:
	var updated = cooldowns.duplicate()
	var to_remove = []
	
	for action_id in updated:
		updated[action_id] -= 1
		if updated[action_id] <= 0:
			to_remove.append(action_id)
	
	for action_id in to_remove:
		updated.erase(action_id)
	
	return updated

## 應用動作冷卻
static func apply_cooldown(cooldowns: Dictionary, action_id: String, cooldown_turns: int) -> Dictionary:
	var updated = cooldowns.duplicate()
	if cooldown_turns > 0:
		updated[action_id] = cooldown_turns
	return updated

# ==================== 動作驗證 ====================

## 驗證動作是否合法（用於伺服器端驗證）
static func validate_action(
	character_current_sta: int,
	character_current_mp: int,
	character_max_sta: int,
	character_max_mp: int,
	action: Action,
	cooldowns: Dictionary
) -> Dictionary:
	var errors: Array[String] = []
	
	# 檢查冷卻
	if is_action_on_cooldown(cooldowns, action.id):
		errors.append("Action is on cooldown")
	
	# 檢查資源
	if not can_afford_action(character_current_sta, character_current_mp, action.cost_stamina, action.cost_mp):
		errors.append("Insufficient resources")
	
	# 檢查 HP（健全性檢查）
	if character_current_sta < 0 or character_current_sta > character_max_sta:
		errors.append("Invalid STA state")
	if character_current_mp < 0 or character_current_mp > character_max_mp:
		errors.append("Invalid MP state")
	
	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

# ==================== 狀態變更計算 ====================

## 計算新 HP（含上下限）
static func calculate_new_hp(current_hp: int, change: int, max_hp: int) -> int:
	return clamp(current_hp + change, 0, max_hp)

## 計算新 MP（含上下限）
static func calculate_new_mp(current_mp: int, change: int, max_mp: int) -> int:
	return clamp(current_mp + change, 0, max_mp)

## 計算新 STA（含上下限）
static func calculate_new_sta(current_sta: int, change: int, max_sta: int) -> int:
	return clamp(current_sta + change, 0, max_sta)

# ==================== 戰鬥狀態檢查 ====================

## 檢查角色是否已死亡
static func is_character_defeated(current_hp: int) -> bool:
	return current_hp <= 0

## 檢查戰鬥是否應該結束
static func is_battle_ended(p1_hp: int, p2_hp: int) -> bool:
	return is_character_defeated(p1_hp) or is_character_defeated(p2_hp)

## 獲取勝者（如果戰鬥結束）
static func get_winner(p1_hp: int, p2_hp: int) -> int:
	if is_character_defeated(p1_hp) and not is_character_defeated(p2_hp):
		return 2  # Player 2 wins
	elif is_character_defeated(p2_hp) and not is_character_defeated(p1_hp):
		return 1  # Player 1 wins
	elif is_character_defeated(p1_hp) and is_character_defeated(p2_hp):
		return 0  # Draw
	else:
		return -1  # Battle not ended
