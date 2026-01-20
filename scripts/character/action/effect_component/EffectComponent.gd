# EffectComponent.gd
# 所有行動效果的抽象基類
# 這是積木式系統的核心接口，所有具體效果都必須繼承此類

extends Resource
class_name EffectComponent

# ==================== 枚舉定義 ====================

## 執行時機
enum ExecutionTime {
	ON_USE,       # 使用時立即執行（無論命中與否）
	ON_HIT,       # 命中時執行
	ON_MISS,      # 未命中時執行
	ON_CRIT,      # 爆擊時執行
	ON_KILL       # 擊殺時執行
}

## 觸發條件類型
enum ConditionType {
	ALWAYS,                  # 無條件執行
	TARGET_STANCE_IS,        # 目標姿態為特定類型
	TARGET_STANCE_NOT,       # 目標姿態不是特定類型
	TARGET_HEALTH_BELOW,     # 目標血量低於 X%
	TARGET_HEALTH_ABOVE,     # 目標血量高於 X%
	USER_HEALTH_BELOW,       # 使用者血量低於 X%
	USER_HEALTH_ABOVE,       # 使用者血量高於 X%
	TARGET_HAS_STATUS,       # 目標擁有特定狀態
	TARGET_NOT_HAS_STATUS,   # 目標沒有特定狀態
	RANDOM_CHANCE,           # 隨機機率（0.0-1.0）
	TURN_NUMBER_MOD,         # 回合數模運算（例如每3回合觸發）
	COMBO_COUNT              # 連擊次數達到 X
}

# ==================== 核心屬性 ====================

## 效果的唯一識別符（用於調試和日誌）
@export var effect_id: String = ""

## 執行時機
@export var execution_time: ExecutionTime = ExecutionTime.ON_HIT

## 觸發條件類型
@export var condition_type: ConditionType = ConditionType.ALWAYS

## 條件參數（類型取決於 condition_type）
## 範例：
## - TARGET_STANCE_IS: Stance.Type.KNOCKED_DOWN
## - TARGET_HEALTH_BELOW: 0.5 (表示 50%)
## - RANDOM_CHANCE: 0.3 (表示 30%)
@export var condition_value: Variant = null

## 效果描述（用於 UI 顯示和調試）
@export var description: String = ""

# ==================== 抽象方法 ====================

## 檢查條件是否滿足
## 子類可以重寫此方法實現自定義條件邏輯
## @param user: 使用技能的角色
## @param target: 目標角色
## @param context: 執行上下文（包含 battle_manager, action, turn 等）
## @return: true 如果條件滿足
func check_condition(user: Character, target: Character, context: Dictionary) -> bool:
	# 基礎條件檢查邏輯
	match condition_type:
		ConditionType.ALWAYS:
			return true
		
		ConditionType.TARGET_STANCE_IS:
			if condition_value == null:
				push_error("TARGET_STANCE_IS 條件需要 condition_value")
				return false
			return target.stance_manager.get_current_stance_type() == condition_value
		
		ConditionType.TARGET_STANCE_NOT:
			if condition_value == null:
				push_error("TARGET_STANCE_NOT 條件需要 condition_value")
				return false
			return target.stance_manager.get_current_stance_type() != condition_value
		
		ConditionType.TARGET_HEALTH_BELOW:
			if condition_value == null:
				push_error("TARGET_HEALTH_BELOW 條件需要 condition_value (0.0-1.0)")
				return false
			var battle_manager = context.get("battle_manager")
			if not battle_manager:
				return false
			var current_hp = battle_manager.get_current_hp(target)
			var max_hp = target.max_hp
			return (float(current_hp) / float(max_hp)) < condition_value
		
		ConditionType.TARGET_HEALTH_ABOVE:
			if condition_value == null:
				push_error("TARGET_HEALTH_ABOVE 條件需要 condition_value (0.0-1.0)")
				return false
			var battle_manager = context.get("battle_manager")
			if not battle_manager:
				return false
			var current_hp = battle_manager.get_current_hp(target)
			var max_hp = target.max_hp
			return (float(current_hp) / float(max_hp)) > condition_value
		
		ConditionType.USER_HEALTH_BELOW:
			if condition_value == null:
				push_error("USER_HEALTH_BELOW 條件需要 condition_value (0.0-1.0)")
				return false
			var battle_manager = context.get("battle_manager")
			if not battle_manager:
				return false
			var current_hp = battle_manager.get_current_hp(user)
			var max_hp = user.max_hp
			return (float(current_hp) / float(max_hp)) < condition_value
		
		ConditionType.USER_HEALTH_ABOVE:
			if condition_value == null:
				push_error("USER_HEALTH_ABOVE 條件需要 condition_value (0.0-1.0)")
				return false
			var battle_manager = context.get("battle_manager")
			if not battle_manager:
				return false
			var current_hp = battle_manager.get_current_hp(user)
			var max_hp = user.max_hp
			return (float(current_hp) / float(max_hp)) > condition_value
		
		ConditionType.TARGET_HAS_STATUS:
			if condition_value == null:
				push_error("TARGET_HAS_STATUS 條件需要 condition_value (status_id)")
				return false
			return target.has_status_effect(condition_value)
		
		ConditionType.TARGET_NOT_HAS_STATUS:
			if condition_value == null:
				push_error("TARGET_NOT_HAS_STATUS 條件需要 condition_value (status_id)")
				return false
			return not target.has_status_effect(condition_value)
		
		ConditionType.RANDOM_CHANCE:
			if condition_value == null:
				push_error("RANDOM_CHANCE 條件需要 condition_value (0.0-1.0)")
				return false
			return randf() < condition_value
		
		ConditionType.TURN_NUMBER_MOD:
			if condition_value == null or not condition_value is int:
				push_error("TURN_NUMBER_MOD 條件需要 condition_value (整數)")
				return false
			var battle_manager = context.get("battle_manager")
			if not battle_manager or not battle_manager.state:
				return false
			return battle_manager.state.turn % condition_value == 0
		
		ConditionType.COMBO_COUNT:
			if condition_value == null:
				push_error("COMBO_COUNT 條件需要 condition_value (整數)")
				return false
			var combo = context.get("combo_count", 0)
			return combo >= condition_value
	
	# 未知條件類型
	push_error("未知的條件類型: %s" % condition_type)
	return false

## 執行效果（抽象方法，必須由子類實現）
## @param user: 使用技能的角色
## @param target: 目標角色
## @param context: 執行上下文（包含 battle_manager, action, turn, hit_result 等）
## @return: 執行結果字典（格式由子類決定）
func execute(user: Character, target: Character, context: Dictionary) -> Dictionary:
	push_error("EffectComponent.execute() 是抽象方法，必須由子類實現")
	return {}

## 獲取效果的簡短描述（用於 UI 顯示）
func get_display_text() -> String:
	if description:
		return description
	return "未定義效果"

## 獲取條件的描述文本
func get_condition_text() -> String:
	match condition_type:
		ConditionType.ALWAYS:
			return "無條件"
		ConditionType.TARGET_STANCE_IS:
			return "目標姿態為 %s 時" % Stance.get_stance_name(condition_value)
		ConditionType.TARGET_HEALTH_BELOW:
			return "目標血量低於 %d%% 時" % (condition_value * 100)
		ConditionType.TARGET_HEALTH_ABOVE:
			return "目標血量高於 %d%% 時" % (condition_value * 100)
		ConditionType.RANDOM_CHANCE:
			return "%d%% 機率" % (condition_value * 100)
		_:
			return "特殊條件"

func _to_string() -> String:
	return "EffectComponent(%s, %s)" % [effect_id if effect_id else "unnamed", get_condition_text()]
