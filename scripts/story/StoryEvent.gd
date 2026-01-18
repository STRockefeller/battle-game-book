# StoryEvent.gd
# 故事事件數據結構 - 可觸發的故事節點

class_name StoryEvent
extends Resource

# ==================== 事件基本信息 ====================
@export var event_id: String
@export var event_title: String
@export_multiline var event_description: String

# ==================== 觸發條件 ====================
@export var trigger_type: String = "energy"  # "energy", "battle_count", "manual", "stage"
@export var trigger_value: float = 0.0  # 根據trigger_type解釋不同

# ==================== 事件類型 ====================
@export var event_type: String = "narrative"  # "narrative", "choice", "battle", "divine_favor"

# ==================== 選擇型事件 ====================
@export var choices: Array[Resource] = []  # Array of EventChoice

# ==================== 事件結果 ====================
@export var energy_change: float = 0.0
@export var unlock_abilities: Array[String] = []
@export var lock_abilities: Array[String] = []
@export var story_flags: Dictionary = {}  # 設置故事標記

# ==================== 視覺效果 ====================
@export var background_scene: String = ""
@export var character_sprite: String = ""
@export var audio_bgm: String = ""
@export var audio_sfx: String = ""

## 檢查事件是否可觸發
func can_trigger(story_progress: Dictionary) -> bool:
	match trigger_type:
		"energy":
			return story_progress.get("world_energy", 0.0) <= trigger_value
		"battle_count":
			return story_progress.get("battles_completed", 0) >= int(trigger_value)
		"stage":
			return story_progress.get("current_stage", 0) == int(trigger_value)
		"manual":
			return true
		_:
			return false
