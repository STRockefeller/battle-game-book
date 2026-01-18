# StoryData.gd
# 故事模式核心數據結構 - 可由外部資源文件輕鬆編輯

class_name StoryData
extends Resource

# ==================== 基本信息 ====================
@export var story_id: String
@export var character_id: String
@export_multiline var story_title: String
@export_multiline var story_description: String

# ==================== 故鄉與災變 ====================
@export var homeland_name: String
@export_multiline var homeland_description: String
@export var energy_type: String  # "life", "order", "chaos", "destruction", "creation"

@export var initial_world_energy: float = 50.0  # 初始世界能量 (0-100)
@export var calamity_description: String

# ==================== 開場劇情 ====================
@export_multiline var opening_narrative: String

# ==================== 結局條件 ====================
@export var victory_energy_threshold: float = 80.0
@export var survival_energy_threshold: float = 40.0
@export var defeat_energy_threshold: float = 20.0

@export_multiline var true_ending: String
@export_multiline var neutral_ending: String
@export_multiline var bad_ending: String
@export_multiline var secret_ending: String

# ==================== 故事節點 ====================
@export var story_events: Array[Resource] = []  # Array of StoryEvent

# ==================== 災變階段 ====================
@export var calamity_stages: Array[Resource] = []  # Array of CalamityStage

# ==================== 神明眷顧 ====================
@export var divine_favors: Array[Resource] = []  # Array of DivineFavor

# ==================== 工具函數 ====================

## 根據能量判斷結局類型
func get_ending_type(final_energy: float) -> String:
	if final_energy >= victory_energy_threshold:
		return "true_ending"
	elif final_energy >= survival_energy_threshold:
		return "neutral_ending"
	elif final_energy >= defeat_energy_threshold:
		return "bad_ending"
	else:
		return "secret_ending"

## 獲取結局文本
func get_ending_text(ending_type: String) -> String:
	match ending_type:
		"true_ending":
			return true_ending
		"neutral_ending":
			return neutral_ending
		"bad_ending":
			return bad_ending
		"secret_ending":
			return secret_ending
		_:
			return ""

## 根據能量獲取當前災變階段
func get_current_calamity_stage(current_energy: float) -> Resource:
	for stage in calamity_stages:
		if stage is CalamityStage:
			if current_energy >= stage.min_energy and current_energy <= stage.max_energy:
				return stage
	return null
