# EffectExecutor.gd
# 效果執行器：負責處理 EffectComponent 積木的執行流程
# 包含條件檢查、執行順序、結果匯總等功能

extends RefCounted
class_name EffectExecutor

# ==================== 靜態執行方法 ====================

## 執行指定執行時機的所有效果
## @param action: 要執行的動作
## @param execution_time: 執行時機（ON_USE, ON_HIT, ON_MISS, ON_CRIT, ON_KILL）
## @param user: 使用者角色
## @param target: 目標角色
## @param context: 上下文字典，包含 battle_manager, turn, combo_count, hit_result 等
## @return: 執行結果字典，包含成功的效果列表和失敗的效果列表
static func execute_effects(
	action: Action,
	execution_time: EffectComponent.ExecutionTime,
	user: Character,
	target: Character,
	context: Dictionary
) -> Dictionary:
	var results = {
		"execution_time": EffectComponent.ExecutionTime.keys()[execution_time],
		"effects_executed": [],
		"effects_failed": [],
		"total_damage": 0,
		"total_healing": 0,
		"statuses_applied": []
	}
	
	# 檢查動作是否使用新系統
	if not action.uses_effect_components():
		print("[EffectExecutor] 動作 %s 未使用效果積木系統，跳過執行" % action.name)
		return results
	
	# 獲取該執行時機的所有效果
	var effects = action.get_effects_by_time(execution_time)
	if effects.size() == 0:
		return results
	
	print("[EffectExecutor] 執行 %d 個效果（時機：%s）" % [
		effects.size(),
		EffectComponent.ExecutionTime.keys()[execution_time]
	])
	
	# 逐個執行效果
	for effect in effects:
		var result = _execute_single_effect(effect, user, target, context)
		
		if result.get("success", false):
			results["effects_executed"].append({
				"effect": effect,
				"result": result
			})
			
			# 匯總結果
			_aggregate_result(results, result)
		else:
			results["effects_failed"].append({
				"effect": effect,
				"reason": result.get("reason", "unknown")
			})
	
	return results

## 執行單個效果積木
static func _execute_single_effect(
	effect: EffectComponent,
	user: Character,
	target: Character,
	context: Dictionary
) -> Dictionary:
	# 檢查條件
	if not effect.check_condition(user, target, context):
		return {
			"success": false,
			"reason": "condition_not_met",
			"condition": effect.get_condition_text()
		}
	
	# 執行效果
	var result = effect.execute(user, target, context)
	
	print("[EffectExecutor] 效果執行：%s -> %s" % [
		effect.get_display_text(),
		"成功" if result.get("success", false) else "失敗"
	])
	
	return result

## 匯總執行結果（累加傷害、治療等數值）
static func _aggregate_result(results: Dictionary, effect_result: Dictionary) -> void:
	match effect_result.get("type"):
		"damage":
			if effect_result.has("final_damage"):
				results["total_damage"] += effect_result["final_damage"]
		
		"heal":
			if effect_result.has("heal_amount"):
				results["total_healing"] += effect_result["heal_amount"]
		
		"dot", "control", "stat_modifier":
			if effect_result.get("status_applied", false):
				results["statuses_applied"].append(effect_result.get("status_id", "unknown"))

# ==================== 向後兼容層 ====================

## 檢查並執行舊系統的效果（用於過渡期）
## @deprecated 當所有 Action 遷移完成後應移除
static func execute_legacy_effects(
	action: Action,
	user: Character,
	target: Character,
	battle_manager: BattleManager,
	hit_result: Dictionary
) -> void:
	if action.uses_effect_components():
		return  # 已使用新系統，不執行舊邏輯
	
	# 執行舊的 effects_on_use
	if action.effects_on_use.size() > 0:
		print("[EffectExecutor] [舊系統] 執行 effects_on_use: %s" % str(action.effects_on_use))
		# 這裡需要呼叫舊的效果系統（如果有的話）
	
	# 執行舊的 effects_on_hit（僅當命中時）
	if hit_result.get("hit", false) and action.effects_on_hit.size() > 0:
		print("[EffectExecutor] [舊系統] 執行 effects_on_hit: %s" % str(action.effects_on_hit))
	
	# 執行舊的姿態變更
	if action.target_stance_change_enabled and hit_result.get("hit", false):
		print("[EffectExecutor] [舊系統] 目標姿態變更: %s" % Stance.Type.keys()[action.target_stance_change_to])
		target.change_stance(action.target_stance_change_to)
	
	if action.user_stance_change_enabled:
		print("[EffectExecutor] [舊系統] 使用者姿態變更: %s" % Stance.Type.keys()[action.user_stance_change_to])
		user.change_stance(action.user_stance_change_to)

# ==================== 工具方法 ====================

## 構建上下文字典（包含執行效果所需的所有信息）
static func build_context(
	battle_manager: BattleManager,
	action: Action,
	user: Character,
	target: Character,
	hit_result: Dictionary = {},
	additional_data: Dictionary = {}
) -> Dictionary:
	var context = {
		"battle_manager": battle_manager,
		"action": action,
		"user": user,
		"target": target,
		"turn": battle_manager.state.turn if battle_manager.state else 0,
		"distance": battle_manager.state.distance if battle_manager.state else BattleState.Distance.MID,
		"hit_result": hit_result,
		"hit": hit_result.get("hit", false),
		"critical": hit_result.get("critical", false),
		"miss": not hit_result.get("hit", true),
		"combo_count": 0  # TODO: 從 BattleManager 獲取連擊數
	}
	
	# 合併額外數據
	for key in additional_data:
		context[key] = additional_data[key]
	
	return context

## 格式化執行結果為可讀文本（用於 UI 顯示或日誌）
static func format_results(results: Dictionary) -> String:
	var lines: Array[String] = []
	
	lines.append("=== 效果執行結果 ===")
	lines.append("執行時機: %s" % results.get("execution_time", "未知"))
	lines.append("成功執行: %d 個" % results["effects_executed"].size())
	lines.append("執行失敗: %d 個" % results["effects_failed"].size())
	
	if results["total_damage"] > 0:
		lines.append("總傷害: %d" % results["total_damage"])
	
	if results["total_healing"] > 0:
		lines.append("總治療: %d" % results["total_healing"])
	
	if results["statuses_applied"].size() > 0:
		lines.append("施加狀態: %s" % str(results["statuses_applied"]))
	
	return "\n".join(lines)
