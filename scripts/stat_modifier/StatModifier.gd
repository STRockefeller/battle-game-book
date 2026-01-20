# StatModifier.gd
# 單個屬性修正器定義類
# 定義了對某個屬性的具體修正操作（用於被動特質、神恩等）

class_name StatModifier
extends RefCounted

## 屬性標識符
## 例如: "damage_bonus", "damage_reduction", "critical_rate", "stamina_restore"
var property: String = ""

## 操作類型: "add" / "multiply" / "replace"
## - "add": 直接相加 (e.g., +10% 傷害 → 0.1)
## - "multiply": 百分比乘算 (e.g., 傷害 × 1.25)
## - "replace": 替換原值 (e.g., 強制設置為某個值)
var operation: String = "add"

## 效果值
var value: float = 0.0

## 標籤過濾 - 為空表示作用於所有行動，否則僅作用於帶這些標籤的行動
## 例如: ["physical"] 或 ["magic", "elemental"]
var tags_filter: Array[String] = []

func _init(p_property: String = "", p_operation: String = "add", 
           p_value: float = 0.0, p_tags_filter: Array[String] = []) -> void:
	property = p_property
	operation = p_operation
	value = p_value
	tags_filter = p_tags_filter

## 檢查該效果是否應該作用於給定的標籤
func applies_to_tags(action_tags: Array[String]) -> bool:
	# 如果沒有標籤過濾，作用於所有行動
	if tags_filter.is_empty():
		return true
	
	# 檢查行動是否包含任何過濾標籤
	for tag in action_tags:
		if tag in tags_filter:
			return true
	
	return false

func _to_string() -> String:
	var filter_str = ", tags: [%s]" % ", ".join(tags_filter) if not tags_filter.is_empty() else ""
	return "StatModifier(%s %s %.2f%s)" % [property, operation, value, filter_str]
