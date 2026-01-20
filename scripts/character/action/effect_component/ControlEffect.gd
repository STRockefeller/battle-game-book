# ControlEffect.gd
# 控制效果積木 (Control/Disable Effect)
# 實現行動限制效果，如禁用特定類型的動作、跳過回合等

extends EffectComponent
class_name ControlEffect

# ==================== 枚舉 ====================

## 控制類型
enum ControlType {
	FORBID_TAGS,        # 禁用含有特定標籤的動作
	SKIP_TURN,          # 跳過下一回合（暈眩）
	FORCE_ACTION,       # 強制使用特定動作
	REDUCE_ACCURACY,    # 降低命中率
	REDUCE_DAMAGE       # 降低傷害輸出
}

# ==================== 屬性 ====================

## 控制效果類型
@export var control_type: ControlType = ControlType.FORBID_TAGS

## 禁用的動作標籤列表（當 control_type == FORBID_TAGS 時使用）
@export var forbidden_tags: PackedStringArray = []

## 強制使用的動作 ID（當 control_type == FORCE_ACTION 時使用）
@export var forced_action_id: String = ""

## 數值參數（用於 REDUCE_ACCURACY, REDUCE_DAMAGE 等）
@export var value: float = 0.0

## 持續回合數
@export var duration: int = 1

## 狀態 ID
@export var status_id: String = ""

## 狀態名稱
@export var status_name: String = ""

## 狀態描述
@export var status_description: String = ""

## 是否可疊加
@export var stackable: bool = false

# ==================== 實現 ====================

func execute(user: Character, target: Character, context: Dictionary) -> Dictionary:
	var result = {
		"type": "control",
		"success": false,
		"control_type": ControlType.keys()[control_type],
		"status_applied": false
	}
	
	# 檢查是否需要創建持續狀態
	if duration > 0:
		var status_effect = _create_status_effect()
		
		# 檢查疊加性
		if not stackable and target.has_status_effect(status_id):
			print("[ControlEffect] %s 已有 %s 狀態，無法重複施加" % [
				target.get_display_name(),
				status_name
			])
			result["success"] = false
			return result
		
		# 應用狀態
		target.apply_effect(status_effect)
		result["status_applied"] = true
		print("[ControlEffect] %s 對 %s 施加了 %s (持續 %d 回合)" % [
			user.get_display_name(),
			target.get_display_name(),
			status_name if status_name else _get_default_name(),
			duration
		])
	else:
		# 即時效果（如瞬間跳過本回合）
		_apply_immediate_effect(target, context)
	
	result["success"] = true
	return result

## 應用即時效果
func _apply_immediate_effect(target: Character, context: Dictionary) -> void:
	match control_type:
		ControlType.SKIP_TURN:
			# 標記目標在當前回合失去行動權
			var battle_manager = context.get("battle_manager")
			if battle_manager:
				# 這需要 BattleManager 支持標記玩家跳過回合
				print("[ControlEffect] %s 的回合被跳過！" % target.get_display_name())
		_:
			print("[ControlEffect] 即時控制效果執行：%s" % ControlType.keys()[control_type])

## 創建持續狀態效果
func _create_status_effect() -> StatusEffect:
	var status = StatusEffect.new()
	
	# 基本信息
	status.id = status_id if status_id else "control_" + str(randi())
	status.name = status_name if status_name else _get_default_name()
	status.description = status_description if status_description else _get_default_description()
	
	# 持續時間
	status.duration = duration
	status.duration_type = 0  # TURN
	
	# 分類
	status.is_debuff = true
	status.effect_type = "control"
	
	# 效果參數
	status.effect_parameters = {
		"control_type": ControlType.keys()[control_type],
		"forbidden_tags": forbidden_tags,
		"forced_action_id": forced_action_id,
		"value": value
	}
	
	# 觸發時機
	status.triggers_on_turn_start = true
	
	return status

## 獲取預設名稱
func _get_default_name() -> String:
	match control_type:
		ControlType.FORBID_TAGS:
			if forbidden_tags.size() > 0:
				return "禁用 %s" % forbidden_tags[0]
			return "行動限制"
		ControlType.SKIP_TURN:
			return "暈眩"
		ControlType.FORCE_ACTION:
			return "強制行動"
		ControlType.REDUCE_ACCURACY:
			return "致盲"
		ControlType.REDUCE_DAMAGE:
			return "虛弱"
		_:
			return "控制效果"

## 獲取預設描述
func _get_default_description() -> String:
	match control_type:
		ControlType.FORBID_TAGS:
			return "禁用包含標籤 %s 的動作" % str(forbidden_tags)
		ControlType.SKIP_TURN:
			return "下 %d 回合無法行動" % duration
		ControlType.FORCE_ACTION:
			return "強制使用 %s" % forced_action_id
		ControlType.REDUCE_ACCURACY:
			return "命中率降低 %d%%" % int(value * 100)
		ControlType.REDUCE_DAMAGE:
			return "傷害降低 %d%%" % int(value * 100)
		_:
			return "施加控制效果"

## 重寫顯示文本
func get_display_text() -> String:
	if description:
		return description
	return "施加 %s (持續 %d 回合)" % [
		status_name if status_name else _get_default_name(),
		duration
	]

func _to_string() -> String:
	return "ControlEffect(%s, %d回合, %s)" % [
		ControlType.keys()[control_type],
		duration,
		get_condition_text()
	]
