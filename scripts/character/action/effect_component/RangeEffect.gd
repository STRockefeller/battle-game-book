# RangeEffect.gd
# 距離變更效果積木 (Range Change Effect)
# 實現戰鬥距離的變更，如拉近、推開、傳送等

extends EffectComponent
class_name RangeEffect

# ==================== 枚舉 ====================

## 距離變更類型
enum RangeChangeType {
	SET_DISTANCE,      # 直接設置距離
	INCREASE,          # 增加距離（推開）
	DECREASE,          # 減少距離（拉近）
	TELEPORT           # 傳送到特定距離
}

## 變更目標
enum ChangeTarget {
	BOTH,              # 雙方距離變化
	TARGET_ONLY,       # 只移動目標
	USER_ONLY          # 只移動使用者
}

# ==================== 屬性 ====================

## 變更類型
@export var change_type: RangeChangeType = RangeChangeType.INCREASE

## 變更目標
@export var change_target: ChangeTarget = ChangeTarget.BOTH

## 距離變化值（正數=推開/增加，負數=拉近/減少）
@export var distance_delta: int = 1

## 目標距離（當 change_type == SET_DISTANCE 或 TELEPORT 時使用）
@export var target_distance: int = BattleState.Distance.MID

## 最小距離限制（防止超出範圍）
@export var min_distance: int = BattleState.Distance.NEAR

## 最大距離限制
@export var max_distance: int = BattleState.Distance.FAR

## 是否無視障礙（某些特殊技能可以穿越障礙物）
@export var ignore_obstacles: bool = false

# ==================== 實現 ====================

func execute(user: Character, target: Character, context: Dictionary) -> Dictionary:
	var battle_manager = context.get("battle_manager")
	if not battle_manager:
		push_error("[RangeEffect] 缺少 battle_manager，無法變更距離")
		return {"type": "range", "success": false, "error": "no_battle_manager"}
	
	var current_distance = battle_manager.state.distance if battle_manager.state else BattleState.Distance.MID
	var new_distance = _calculate_new_distance(current_distance)
	
	# 應用距離限制
	new_distance = clamp(new_distance, min_distance, max_distance)
	
	# 檢查是否有實際變化
	if new_distance == current_distance:
		print("[RangeEffect] 距離已達到極限，無法繼續變更")
		return {
			"type": "range",
			"success": false,
			"old_distance": current_distance,
			"new_distance": new_distance,
			"reason": "已達極限"
		}
	
	# 更新戰鬥狀態中的距離
	if battle_manager.state:
		battle_manager.state.distance = new_distance
	
	print("[RangeEffect] 距離變更：%s → %s (類型：%s)" % [
		_distance_to_text(current_distance),
		_distance_to_text(new_distance),
		RangeChangeType.keys()[change_type]
	])
	
	return {
		"type": "range",
		"success": true,
		"old_distance": current_distance,
		"new_distance": new_distance,
		"change_type": RangeChangeType.keys()[change_type]
	}

## 計算新距離
func _calculate_new_distance(current: int) -> int:
	match change_type:
		RangeChangeType.SET_DISTANCE:
			return target_distance
		
		RangeChangeType.INCREASE:
			return current + abs(distance_delta)
		
		RangeChangeType.DECREASE:
			return current - abs(distance_delta)
		
		RangeChangeType.TELEPORT:
			return target_distance
		
		_:
			return current

## 獲取方向文本（用於顯示）
func _get_direction_text() -> String:
	match change_type:
		RangeChangeType.INCREASE:
			return "推開"
		RangeChangeType.DECREASE:
			return "拉近"
		RangeChangeType.SET_DISTANCE, RangeChangeType.TELEPORT:
			return "移動到"
		_:
			return "變更"

## 重寫顯示文本
func get_display_text() -> String:
	if description:
		return description
	
	match change_type:
		RangeChangeType.SET_DISTANCE, RangeChangeType.TELEPORT:
			return "%s至距離 %s" % [_get_direction_text(), _distance_to_text(target_distance)]
		RangeChangeType.INCREASE:
			return "%s %d 距離" % [_get_direction_text(), abs(distance_delta)]
		RangeChangeType.DECREASE:
			return "%s %d 距離" % [_get_direction_text(), abs(distance_delta)]
		_:
			return "變更戰鬥距離"

func _to_string() -> String:
	return "RangeEffect(%s, delta=%d, target=%d, %s)" % [
		RangeChangeType.keys()[change_type],
		distance_delta,
		target_distance,
		get_condition_text()
	]

func _distance_to_text(value: int) -> String:
	match value:
		BattleState.Distance.NEAR:
			return "近距離"
		BattleState.Distance.MID:
			return "中距離"
		BattleState.Distance.FAR:
			return "遠距離"
		_:
			return str(value)
