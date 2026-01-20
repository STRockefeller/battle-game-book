# StatModifierEffect.gd
# 屬性修改效果積木 (Stat Modifier Effect)
# 實現臨時的屬性增減效果，如攻擊力提升、防禦力降低等
# 注意：這是戰鬥中的臨時效果，與 character/passive_trait/StatModifier 不同

extends EffectComponent
class_name StatModifierEffect

# ==================== 枚舉 ====================

## 修改類型
enum ModifierType {
	FLAT,              # 固定數值增減（如 +10 攻擊力）
	PERCENTAGE,        # 百分比增減（如 +20% 防禦力）
	MULTIPLY           # 倍數增減（如 1.5 倍傷害）
}

## 影響的屬性類型（對應 Character 和 BattleState 中的屬性）
enum StatType {
	# 基礎屬性（來自 Character）
	STR,               # 力量
	INT,               # 智力
	AGI,               # 敏捷
	CON,               # 體質
	LUK,               # 幸運
	
	# 戰鬥屬性（來自 Character 計算值）
	MAX_HP,            # 最大生命值
	MAX_MP,            # 最大魔力值
	MAX_STAMINA,       # 最大體力值
	ATK,               # 攻擊力
	DEF,               # 防禦力
	MAG,               # 魔法攻擊
	RES,               # 魔法抗性
	SPD,               # 速度
	ACC,               # 命中率
	EVA,               # 迴避率
	CRT,               # 暴擊率
	
	# 特殊修正（直接影響傷害計算）
	DAMAGE_DEALT,      # 造成的傷害修正
	DAMAGE_TAKEN,      # 受到的傷害修正
	HEALING_GIVEN,     # 給予的治療修正
	HEALING_RECEIVED   # 受到的治療修正
}

# ==================== 屬性 ====================

## 修改類型
@export var modifier_type: ModifierType = ModifierType.PERCENTAGE

## 影響的屬性
@export var stat_type: StatType = StatType.ATK

## 修改數值
## - FLAT: 直接加減的數值（如 10 表示 +10）
## - PERCENTAGE: 百分比（如 0.2 表示 +20%）
## - MULTIPLY: 倍數（如 1.5 表示 1.5 倍）
@export var value: float = 0.0

## 持續回合數（0 表示永久，直到戰鬥結束）
@export var duration: int = 3

## 狀態 ID
@export var status_id: String = ""

## 狀態名稱
@export var status_name: String = ""

## 狀態描述
@export var status_description: String = ""

## 是否可疊加
@export var stackable: bool = true

## 圖示路徑
@export var icon_path: String = ""

# ==================== 實現 ====================

func execute(user: Character, target: Character, context: Dictionary) -> Dictionary:
	var result = {
		"type": "stat_modifier",
		"success": false,
		"status_applied": false,
		"stat_type": StatType.keys()[stat_type],
		"modifier_type": ModifierType.keys()[modifier_type],
		"value": value
	}
	
	# 創建持續狀態效果
	var status_effect = _create_status_effect()
	
	# 檢查疊加性
	if not stackable and target.has_status_effect(status_id):
		print("[StatModifierEffect] %s 已有 %s 狀態，無法重複施加" % [
			target.get_display_name(),
			status_name
		])
		result["success"] = false
		return result
	
	# 應用狀態
	target.apply_effect(status_effect)
	
	print("[StatModifierEffect] %s 對 %s 施加了 %s：%s %s (持續 %d 回合)" % [
		user.get_display_name(),
		target.get_display_name(),
		status_name if status_name else _get_default_name(),
		StatType.keys()[stat_type],
		_format_value(),
		duration if duration > 0 else 999
	])
	
	result["success"] = true
	result["status_applied"] = true
	return result

## 創建持續狀態效果
func _create_status_effect() -> StatusEffect:
	var status = StatusEffect.new()
	
	# 基本信息
	status.id = status_id if status_id else "stat_mod_" + str(randi())
	status.name = status_name if status_name else _get_default_name()
	status.description = status_description if status_description else _get_default_description()
	
	# 持續時間
	status.duration = duration if duration > 0 else 999
	status.duration_type = 0  # TURN
	
	# 分類
	status.is_debuff = (value < 0)
	status.effect_type = "stat_modifier"
	
	# 效果參數（StatusEffect 使用 stat_modifiers 字典）
	status.stat_modifiers = _create_stat_modifier_dict()
	
	return status

## 創建屬性修改字典（符合 StatusEffect 的格式）
func _create_stat_modifier_dict() -> Dictionary:
	var stat_name = StatType.keys()[stat_type].to_lower()
	var modifier_dict = {}
	
	match modifier_type:
		ModifierType.FLAT:
			modifier_dict[stat_name] = value
		
		ModifierType.PERCENTAGE:
			modifier_dict[stat_name + "_percent"] = value
		
		ModifierType.MULTIPLY:
			modifier_dict[stat_name + "_multiplier"] = value
	
	return modifier_dict

## 格式化數值顯示
func _format_value() -> String:
	var sign = "+" if value >= 0 else ""
	
	match modifier_type:
		ModifierType.FLAT:
			return "%s%d" % [sign, int(value)]
		
		ModifierType.PERCENTAGE:
			return "%s%d%%" % [sign, int(value * 100)]
		
		ModifierType.MULTIPLY:
			return "x%.1f" % value
		
		_:
			return str(value)

## 獲取預設名稱
func _get_default_name() -> String:
	var stat_name = _get_stat_chinese_name()
	
	if value > 0:
		return "%s提升" % stat_name
	else:
		return "%s降低" % stat_name

## 獲取屬性中文名稱
func _get_stat_chinese_name() -> String:
	match stat_type:
		StatType.STR:
			return "力量"
		StatType.INT:
			return "智力"
		StatType.AGI:
			return "敏捷"
		StatType.CON:
			return "體質"
		StatType.LUK:
			return "幸運"
		StatType.MAX_HP:
			return "最大生命"
		StatType.MAX_MP:
			return "最大魔力"
		StatType.MAX_STAMINA:
			return "最大體力"
		StatType.ATK:
			return "攻擊力"
		StatType.DEF:
			return "防禦力"
		StatType.MAG:
			return "魔法攻擊"
		StatType.RES:
			return "魔法抗性"
		StatType.SPD:
			return "速度"
		StatType.ACC:
			return "命中率"
		StatType.EVA:
			return "迴避率"
		StatType.CRT:
			return "暴擊率"
		StatType.DAMAGE_DEALT:
			return "造成傷害"
		StatType.DAMAGE_TAKEN:
			return "受到傷害"
		StatType.HEALING_GIVEN:
			return "治療效果"
		StatType.HEALING_RECEIVED:
			return "受療效果"
		_:
			return "未知屬性"

## 獲取預設描述
func _get_default_description() -> String:
	return "%s %s" % [
		_get_stat_chinese_name(),
		_format_value()
	]

## 重寫顯示文本
func get_display_text() -> String:
	if description:
		return description
	
	return "施加 %s：%s %s (持續 %d 回合)" % [
		status_name if status_name else _get_default_name(),
		_get_stat_chinese_name(),
		_format_value(),
		duration if duration > 0 else 999
	]

func _to_string() -> String:
	return "StatModifierEffect(%s, %s %s, %d回合, %s)" % [
		StatType.keys()[stat_type],
		ModifierType.keys()[modifier_type],
		_format_value(),
		duration,
		get_condition_text()
	]
