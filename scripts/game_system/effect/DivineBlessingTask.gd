# DivineBlessingTask.gd
# 神恩任務定義 - 包含任務要求和完成後的效果

class_name DivineBlessingTask
extends RefCounted

## 神恩任務所屬的神明ID
var deity_id: String = ""

## 任務難度: 0=簡單, 1=標準, 2=困難
var difficulty: int = 0

## 任務名稱
var name: String = ""

## 任務要求描述
var requirement: String = ""

## 任務進度追蹤數據
var progress_data: Dictionary = {}

## 是否已完成
var completed: bool = false

## 完成後的加護效果
var blessing_modifiers: Array[StatModifier] = []

## 加護效果的觸發條件
var blessing_conditions: Array[ModifierCondition] = []

## 任務判定腳本/邏輯類型
var progress_script: String = ""  # "action_count", "custom", etc

## 任務條件參數字典
var condition_params: Dictionary = {}

func _init(p_deity_id: String = "", p_difficulty: int = 0, p_name: String = "") -> void:
	deity_id = p_deity_id
	difficulty = p_difficulty
	name = p_name

## 獲取難度名稱
func get_difficulty_name() -> String:
	match difficulty:
		0: 
			return "簡單"
		1: 
			return "標準"
		2: 
			return "困難"
		_: 
			return "未知"

## 檢查條件是否滿足(用於更新進度)
func check_progress(_character: Character, _opponent: Character, 
					_action: Action, _turn: int) -> void:
	# 由具體的任務判定腳本處理
	# 這裡作為基礎框架，具體實現在子類或Battle系統中
	pass

## 更新任務進度
func update_progress(_data: Dictionary) -> void:
	# 根據條件參數更新進度
	pass

## 檢查是否完成
func is_completed() -> bool:
	return completed

## 完成任務時調用
func complete() -> void:
	completed = true

## 轉換為效果修正器
func to_group() -> ModifierGroup:
	var group = ModifierGroup.new(deity_id + "_blessing", "divine", blessing_modifiers)
	if not blessing_conditions.is_empty():
		group.condition = blessing_conditions[0]
	return group

func _to_string() -> String:
	var status = "已完成" if completed else "進行中"
	return "DivineBlessingTask(%s - %s: %s)" % [deity_id, get_difficulty_name(), status]
