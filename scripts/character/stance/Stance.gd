# Stance.gd
# 姿態系統 - 定義所有角色可能的姿態

class_name Stance

# ==================== 姿態枚舉 ====================

enum Type {
	STANDING,      # 站立（預設）
	KNOCKED_DOWN,  # 倒地
	AIRBORNE,      # 滯空
	GUARDING       # 防禦
}

# ==================== 姿態信息 ====================

var type: Type
var remaining_duration: int  # 持續時間（-1 表示無限制）

# ==================== 初始化 ====================

func _init(p_type: Type = Type.STANDING, duration: int = -1) -> void:
	type = p_type
	remaining_duration = duration

# ==================== 靜態方法 - 獲取姿態信息 ====================

## 獲取姿態的名稱
static func get_name(stance_type: Type) -> String:
	match stance_type:
		Type.STANDING:
			return "站立"
		Type.KNOCKED_DOWN:
			return "倒地"
		Type.AIRBORNE:
			return "滯空"
		Type.GUARDING:
			return "防禦"
		_:
			return "未知"

## 獲取姿態的描述
static func get_description(stance_type: Type) -> String:
	match stance_type:
		Type.STANDING:
			return "正常狀態，可以執行所有基礎動作"
		Type.KNOCKED_DOWN:
			return "被擊倒在地，只能選擇「起身」動作"
		Type.AIRBORNE:
			return "懸浮在空中，只能執行空中動作"
		Type.GUARDING:
			return "防禦姿態，防禦力大幅提升但無法攻擊"
		_:
			return ""

## 檢查姿態是否可以執行特定的動作類型
static func can_perform_action(stance_type: Type, action_tag: String) -> bool:
	match stance_type:
		Type.STANDING:
			# 站立可以執行所有動作
			return true
		
		Type.KNOCKED_DOWN:
			# 倒地只能起身
			return action_tag == "stand_up"
		
		Type.AIRBORNE:
			# 滯空只能執行空中動作
			return action_tag in ["aerial_attack", "aerial_skill"]
		
		Type.GUARDING:
			# 防禦只能執行防禦相關動作
			return action_tag in ["guard", "counter_guard"]
		
		_:
			return false

# ==================== 回合更新 ====================

## 在回合結束時減少持續時間
func on_turn_end() -> void:
	if remaining_duration > 0:
		remaining_duration -= 1

## 檢查姿態是否已過期
func is_expired() -> bool:
	return remaining_duration == 0
