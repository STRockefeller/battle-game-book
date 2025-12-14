# BattleLogic.gd
# 無狀態的對戰核心邏輯 - 支援確定性計算和伺服器驗證
# 所有計算都是純函數，輸入相同則輸出必定相同，便於網路同步

extends RefCounted
class_name BattleLogic

# ==================== 命中判定 ====================

## 根據固定命中率計算命中（簡化後的系統）
## accuracy: 動作的固定命中率 (0-100)
## accuracy_bonus: 角色被動特質的加成 (-30 到 +30)
## rng_seed: 確定性 RNG 種子
func calculate_hit(action_accuracy: float, accuracy_bonus: int = 0, rng_seed: int = 0) -> bool:
	var rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	
	# 計算最終命中率 (0-100%)
	var final_accuracy = clamp(action_accuracy + accuracy_bonus, 5.0, 95.0)
	return rng.randf() * 100 < final_accuracy

## 靜態版本 - 不需要 Node 實例
static func calculate_hit_static(action_accuracy: float, accuracy_bonus: int = 0, rng_seed: int = 0) -> bool:
	var rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	var final_accuracy = clamp(action_accuracy + accuracy_bonus, 5.0, 95.0)
	return rng.randf() * 100 < final_accuracy

# ==================== 傷害計算 ====================

## 計算實際傷害（簡化後的系統）
## base_damage: 動作的固定傷害值
## damage_bonus_percent: 角色被動特質的傷害加成百分比 (-100% 到 +200%)
## defense_reduction_percent: 敵人被動特質的減傷百分比 (0% 到 90%)
static func calculate_damage_result(base_damage: int, damage_bonus_percent: float = 0.0, defense_reduction_percent: float = 0.0) -> int:
	# 應用傷害加成
	var adjusted_damage = base_damage * (1.0 + damage_bonus_percent / 100.0)
	
	# 應用減傷
	var final_damage = adjusted_damage * (1.0 - defense_reduction_percent / 100.0)
	
	# 至少 1 傷害，向上取整
	return max(1, int(ceil(final_damage)))

## 計算爆擊傷害
## base_damage: 計算後的基礎傷害
## crit_multiplier: 爆擊倍率 (預設 150%, 可由被動提升至 200% 以上)
static func calculate_critical_damage(base_damage: int, crit_multiplier: float = 1.5) -> int:
	return int(base_damage * crit_multiplier)

# ==================== 資源成本檢查 ====================

## 檢查角色是否擁有足夠資源執行動作
static func can_afford_action(current_stamina: int, current_mp: int, cost_stamina: int, cost_mp: int) -> bool:
	return current_stamina >= cost_stamina and current_mp >= cost_mp

## 扣除資源
static func deduct_resources(current_stamina: int, current_mp: int, cost_stamina: int, cost_mp: int) -> Dictionary:
	return {
		"stamina": clamp(current_stamina - cost_stamina, 0, current_stamina),
		"mp": clamp(current_mp - cost_mp, 0, current_mp)
	}

# ==================== 執行順序計算 ====================

# ==================== 執行順序計算 ====================

## 計算機率性先手
## agi_diff: 己方AGI - 敵方AGI
## 公式: 先手機率 = 50% + (AGI差 × 2%)，上限 100%，下限 0%
static func calculate_first_action_probability(agi_diff: int) -> float:
	return clamp(50.0 + (agi_diff * 2.0), 0.0, 100.0)

## 根據 AGI 決定動作執行順序（機率性）
## actions: Array[Dictionary] - 包含 "user_agi", "action" 等資訊的陣列
## 返回按優先度排序的動作陣列，同優先度的行動會同時進行
static func calculate_execution_order(actions: Array) -> Array:
	var order = actions.duplicate()
	
	# 計算每個行動的優先度分數（AGI × 100 + action priority）
	order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_agi = a.get("user_agi", 10)
		var b_agi = b.get("user_agi", 10)
		var a_priority = a.get("priority", 0)
		var b_priority = b.get("priority", 0)
		
		# 基礎優先度 = AGI × 100
		var a_score = a_agi * 100 + a_priority
		var b_score = b_agi * 100 + b_priority
		
		return a_score > b_score  # 高優先度先執行
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
	character_current_stamina: int,
	character_current_mp: int,
	character_max_stamina: int,
	character_max_mp: int,
	action: Action,
	cooldowns: Dictionary
) -> Dictionary:
	var errors: Array[String] = []
	
	# 檢查冷卻
	if is_action_on_cooldown(cooldowns, action.id):
		errors.append("Action is on cooldown")
	
	# 檢查資源
	if not can_afford_action(character_current_stamina, character_current_mp, action.cost_stamina, action.cost_mp):
		errors.append("Insufficient resources")
	
	# 檢查 HP（健全性檢查）
	if character_current_stamina < 0 or character_current_stamina > character_max_stamina:
		errors.append("Invalid stamina state")
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

## 計算新 Stamina（含上下限）
static func calculate_new_stamina(current_stamina: int, change: int, max_stamina: int) -> int:
	return clamp(current_stamina + change, 0, max_stamina)

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
