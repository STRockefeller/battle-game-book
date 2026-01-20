# PassiveTrait.gd
# 被動特質定義 - 改為純代碼定義，不使用tres資源文件

class_name PassiveTrait
extends RefCounted

## 特質唯一標識
var id: String = ""

## 特質名稱
var name: String = ""

## 特質描述
var description: String = ""

## 該特質提供的修正器列表
var modifiers: Array[StatModifier] = []

## 條件觸發(可為null表示無條件)
var conditions: Array[ModifierCondition] = []

## 不能與哪些特質共存
var incompatible_trait_ids: Array[String] = []

## 與哪些神明相容(用於推理提示)
var synergy_deity_ids: Array[String] = []

## 與哪些神明剋制(用於推理提示)
var counter_deity_ids: Array[String] = []

func _init(p_id: String = "", p_name: String = "", p_description: String = "") -> void:
    id = p_id
    name = p_name
    description = p_description

## 轉換為修正器組
func to_group() -> ModifierGroup:
    var group = ModifierGroup.new(id, "passive", modifiers)
    if not conditions.is_empty():
        group.condition = conditions[0]  # 當前支持單條件，可擴展
    return group

## 檢查是否與另一個特質衝突
func conflicts_with(other_trait: PassiveTrait) -> bool:
    return other_trait.id in incompatible_trait_ids

func _to_string() -> String:
    return "PassiveTrait(%s: %s)" % [id, name]

func get_stat_modifier(_stat_type: String) -> float:
    return 0.0  # PassiveTrait本身不直接提供stat_modifiers，通過effects實現

## 計算應用後的統計值
func apply_modifier_to_stat(base_value: float, stat_type: String) -> float:
    var modifier = get_stat_modifier(stat_type)
    if stat_type.contains("bonus"):
        return base_value * (1.0 + modifier)
    else:
        return base_value + modifier