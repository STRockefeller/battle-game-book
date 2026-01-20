# StanceEffect.gd
# 姿態變更效果積木
# 實現戰鬥姿態的切換邏輯，可以改變使用者或目標的姿態

extends EffectComponent
class_name StanceEffect

# ==================== 枚舉 ====================

## 變更對象
enum ChangeTarget {
	USER,      # 變更使用者的姿態
	TARGET     # 變更目標的姿態
}

# ==================== 屬性 ====================

## 變更對象（使用者或目標）
@export var change_target: ChangeTarget = ChangeTarget.TARGET

## 目標姿態類型
@export var new_stance: Stance.Type = Stance.Type.STANDING

## 姿態持續時間（-1 表示永久，直到被其他效果改變）
@export var duration: int = -1

## 是否強制變更（無視當前姿態的限制）
@export var force_change: bool = false

# ==================== 實現 ====================

func execute(user: Character, target: Character, context: Dictionary) -> Dictionary:
	var result = {
		"type": "stance_change",
		"success": false,
		"target_name": "",
		"from_stance": "",
		"to_stance": ""
	}
	
	# 決定要變更誰的姿態
	var affected_character: Character
	if change_target == ChangeTarget.USER:
		affected_character = user
		result["target_name"] = user.get_display_name()
	else:
		affected_character = target
		result["target_name"] = target.get_display_name()
	
	# 獲取當前姿態
	var current_stance = affected_character.stance_manager.get_current_stance_type()
	result["from_stance"] = Stance.get_stance_name(current_stance)
	result["to_stance"] = Stance.get_stance_name(new_stance)
	
	# 檢查是否需要變更
	if current_stance == new_stance:
		print("[StanceEffect] %s 已經處於 %s 姿態，無需變更" % [
			affected_character.get_display_name(),
			Stance.get_stance_name(new_stance)
		])
		result["success"] = false
		return result
	
	# 執行姿態變更
	affected_character.change_stance(new_stance, duration)
	
	# 更新 BattleManager 中的姿態狀態
	var battle_manager = context.get("battle_manager")
	if battle_manager:
		_update_battle_manager_stance(affected_character, new_stance, battle_manager)
	
	print("[StanceEffect] %s 的姿態從 %s 變更為 %s" % [
		affected_character.get_display_name(),
		Stance.get_stance_name(current_stance),
		Stance.get_stance_name(new_stance)
	])
	
	result["success"] = true
	return result

## 更新 BattleManager 中的姿態記錄
func _update_battle_manager_stance(character: Character, stance_type: Stance.Type, battle_manager) -> void:
	if not battle_manager or not battle_manager.state:
		return
	
	# 判斷是 player1 還是 player2
	if character == battle_manager.player1:
		battle_manager.state.p1_stance = stance_type
	elif character == battle_manager.player2:
		battle_manager.state.p2_stance = stance_type

## 獲取變更對象名稱
func get_change_target_name() -> String:
	return "使用者" if change_target == ChangeTarget.USER else "目標"

## 重寫顯示文本
func get_display_text() -> String:
	if description:
		return description
	
	var text = "將 %s 的姿態變更為 %s" % [
		get_change_target_name(),
		Stance.get_stance_name(new_stance)
	]
	
	if duration > 0:
		text += " (持續 %d 回合)" % duration
	
	return text

func _to_string() -> String:
	return "StanceEffect(%s → %s, %s)" % [
		get_change_target_name(),
		Stance.get_stance_name(new_stance),
		get_condition_text()
	]
