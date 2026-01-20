# DOTEffect.gd  
# 持續傷害/回復效果積木 (Damage Over Time / Heal Over Time)
# 實現週期性的生命值/魔力值變化，如中毒、燃燒、回血等

extends EffectComponent
class_name DOTEffect

# ==================== 枚舉 ====================

## 效果類型
enum EffectType {
	DAMAGE,    # 持續傷害
	HEAL       # 持續回復
}

## 影響的資源類型
enum ResourceType {
	HP,        # 生命值
	MP,        # 魔力值
	STAMINA    # 體力值
}

# ==================== 屬性 ====================

## 效果類型（傷害或回復）
@export var effect_type: EffectType = EffectType.DAMAGE

## 影響的資源
@export var resource_type: ResourceType = ResourceType.HP

## 每回合的數值變化
@export var value_per_turn: int = 5

## 持續回合數
@export var duration: int = 3

## 狀態ID（用於識別和移除）
@export var status_id: String = ""

## 狀態名稱（用於 UI 顯示）
@export var status_name: String = ""

## 狀態描述
@export var status_description: String = ""

## 是否可疊加（同一個狀態可以多次施加）
@export var stackable: bool = true

## 狀態圖示路徑（可選）
@export var icon_path: String = ""

# ==================== 實現 ====================

func execute(user: Character, target: Character, context: Dictionary) -> Dictionary:
	var result = {
		"type": "dot",
		"success": false,
		"status_applied": false,
		"status_id": status_id
	}
	
	# 創建持續性狀態效果
	var status_effect = _create_status_effect()
	
	# 檢查目標是否已有此狀態
	if not stackable and target.has_status_effect(status_id):
		print("[DOTEffect] %s 已有 %s 狀態，無法重複施加" % [
			target.get_display_name(),
			status_name
		])
		result["success"] = false
		return result
	
	# 應用狀態到目標
	target.apply_effect(status_effect)
	
	print("[DOTEffect] %s 對 %s 施加了 %s (每回合 %s %d %s，持續 %d 回合)" % [
		user.get_display_name(),
		target.get_display_name(),
		status_name,
		"回復" if effect_type == EffectType.HEAL else "損失",
		value_per_turn,
		_get_resource_name(),
		duration
	])
	
	result["success"] = true
	result["status_applied"] = true
	return result

## 創建 StatusEffect 資源
func _create_status_effect() -> StatusEffect:
	var status = StatusEffect.new()
	
	# 基本信息
	status.id = status_id if status_id else "dot_" + str(randi())
	status.name = status_name if status_name else _get_default_name()
	status.description = status_description if status_description else _get_default_description()
	
	# 持續時間
	status.duration = duration
	status.duration_type = 0  # TURN
	
	# 分類
	status.is_debuff = (effect_type == EffectType.DAMAGE)
	status.effect_type = "dot" if effect_type == EffectType.DAMAGE else "hot"
	
	# 效果參數
	status.effect_parameters = {
		"value_per_turn": value_per_turn,
		"resource_type": _get_resource_name().to_lower(),
		"effect_type": "damage" if effect_type == EffectType.DAMAGE else "heal"
	}
	
	# 觸發時機（在回合結束時觸發）
	status.triggers_on_turn_end = true
	
	return status

## 獲取資源類型名稱
func _get_resource_name() -> String:
	match resource_type:
		ResourceType.HP:
			return "HP"
		ResourceType.MP:
			return "MP"
		ResourceType.STAMINA:
			return "體力"
		_:
			return "未知"

## 獲取預設名稱
func _get_default_name() -> String:
	if effect_type == EffectType.DAMAGE:
		match resource_type:
			ResourceType.HP:
				return "中毒"
			ResourceType.MP:
				return "魔力耗損"
			ResourceType.STAMINA:
				return "疲勞"
	else:
		match resource_type:
			ResourceType.HP:
				return "回血"
			ResourceType.MP:
				return "回魔"
			ResourceType.STAMINA:
				return "恢復體力"
	return "持續效果"

## 獲取預設描述
func _get_default_description() -> String:
	var action_text = "損失" if effect_type == EffectType.DAMAGE else "回復"
	return "每回合%s %d %s" % [action_text, value_per_turn, _get_resource_name()]

## 重寫顯示文本
func get_display_text() -> String:
	if description:
		return description
	
	var action_text = "損失" if effect_type == EffectType.DAMAGE else "回復"
	return "施加 %s：每回合%s %d %s (持續 %d 回合)" % [
		status_name if status_name else _get_default_name(),
		action_text,
		value_per_turn,
		_get_resource_name(),
		duration
	]

func _to_string() -> String:
	return "DOTEffect(%s, %d/回合, %d回合, %s)" % [
		status_name if status_name else _get_default_name(),
		value_per_turn,
		duration,
		get_condition_text()
	]
