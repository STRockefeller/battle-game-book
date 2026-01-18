# StoryProgress.gd
# 故事進度追蹤 - 保存當前遊玩狀態

class_name StoryProgress
extends Resource

# ==================== 基本進度 ====================
@export var story_id: String
@export var character_id: String
@export var current_stage: int = 0
@export var battles_completed: int = 0

# ==================== 能量系統 ====================
@export var world_energy: float = 50.0  # 當前世界能量
@export var total_energy_gained: float = 0.0  # 累計獲得的能量
@export var total_energy_lost: float = 0.0  # 累計失去的能量

# ==================== 故事狀態 ====================
@export var completed_events: Array[String] = []  # 已完成的事件ID
@export var unlocked_events: Array[String] = []  # 已解鎖但未完成的事件
@export var story_flags: Dictionary = {}  # 故事標記

# ==================== 角色成長 ====================
@export var unlocked_abilities: Array[String] = []
@export var locked_abilities: Array[String] = []
@export var unlocked_passives: Array[String] = []
@export var character_modifications: Dictionary = {}  # 角色屬性修改

# ==================== 世界狀態 ====================
@export var destroyed_locations: Array[String] = []
@export var deceased_npcs: Array[String] = []
@export var world_changes: Dictionary = {}

# ==================== 真相碎片 ====================
@export var truth_fragments: Array[String] = []  # 收集的真相碎片ID
@export var truth_progress: int = 0  # 真相進度 0-15

# ==================== 道德選擇記錄 ====================
@export var moral_choices: Dictionary = {}  # {"choice_id": "choice_option"}
@export var sacrifice_count: int = 0
@export var protection_count: int = 0

# ==================== 工具函數 ====================

## 增加世界能量
func add_energy(amount: float) -> void:
	world_energy = clamp(world_energy + amount, 0.0, 100.0)
	if amount > 0:
		total_energy_gained += amount

## 減少世界能量
func remove_energy(amount: float) -> void:
	world_energy = clamp(world_energy - amount, 0.0, 100.0)
	if amount > 0:
		total_energy_lost += amount

## 完成事件
func complete_event(event_id: String) -> void:
	if not completed_events.has(event_id):
		completed_events.append(event_id)
	if unlocked_events.has(event_id):
		unlocked_events.erase(event_id)

## 解鎖事件
func unlock_event(event_id: String) -> void:
	if not unlocked_events.has(event_id) and not completed_events.has(event_id):
		unlocked_events.append(event_id)

## 添加真相碎片
func add_truth_fragment(fragment_id: String) -> void:
	if not truth_fragments.has(fragment_id):
		truth_fragments.append(fragment_id)
		truth_progress = truth_fragments.size()

## 檢查是否可進入隱藏結局
func can_access_secret_ending() -> bool:
	return truth_progress >= 15

## 記錄道德選擇
func record_moral_choice(choice_id: String, alignment: String) -> void:
	moral_choices[choice_id] = alignment
	match alignment:
		"sacrifice":
			sacrifice_count += 1
		"protect":
			protection_count += 1
