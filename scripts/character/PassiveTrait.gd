## PassiveTrait.gd
## 被動特質資源類 - 定義角色的被動加成效果
extends Resource
class_name PassiveTrait

# --- 基本信息 ---
@export var id: String = ""              # 被動特質的唯一ID
@export var name: String = ""            # 被動特質的顯示名稱
@export var description: String = ""     # 被動特質的描述

# --- 統計修正 ---
## 統計修正字典，支援以下鍵值：
## - "damage_bonus": float (範圍 -1.0 到 2.0，代表 -100% 到 +200%)
## - "defense_bonus": float (範圍 0.0 到 0.9，代表 0% 到 90%)
## - "accuracy_bonus": int (範圍 -30 到 +30)
## - "evasion_bonus": int (範圍 -30 到 +30)
## - "crit_rate_bonus": float (範圍 0.0 到 0.5，代表 0% 到 50%)
## - "crit_multiplier_bonus": float (倍率加成，如 0.5 = 150% → 200%)
@export var stat_modifiers: Dictionary = {}

# --- 效果參數 ---
## 特質的具體效果參數（如條件、觸發機制等）
## 不同特質可有不同的 effect_parameters 結構
@export var effect_parameters: Dictionary = {}

# --- 特質分類標籤 ---
@export var tags: PackedStringArray = []  # 例如: ["damage", "physical", "passive"]

# --- 初始化 ---
func _init(p_id: String = "", p_name: String = "", p_modifiers: Dictionary = {}) -> void:
	id = p_id
	name = p_name
	stat_modifiers = p_modifiers

## 複製特質（用於動態應用臨時被動）
func duplicate_trait() -> PassiveTrait:
	var new_trait = PassiveTrait.new()
	new_trait.id = id
	new_trait.name = name
	new_trait.description = description
	new_trait.stat_modifiers = stat_modifiers.duplicate()
	new_trait.effect_parameters = effect_parameters.duplicate()
	new_trait.tags = tags.duplicate()
	return new_trait

## 檢查特質是否包含指定標籤
func has_tag(tag: String) -> bool:
	return tags.has(tag)

## 獲取特定統計修正值，如不存在返回 0
func get_stat_modifier(stat_type: String) -> float:
	return stat_modifiers.get(stat_type, 0.0)

## 計算應用後的統計值
func apply_modifier_to_stat(base_value: float, stat_type: String) -> float:
	var modifier = get_stat_modifier(stat_type)
	if stat_type.contains("bonus"):
		return base_value * (1.0 + modifier)
	else:
		return base_value + modifier
