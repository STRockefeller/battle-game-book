# EventChoice.gd
# 事件選擇數據結構

class_name EventChoice
extends Resource

# ==================== 選擇信息 ====================
@export var choice_id: String
@export var choice_text: String
@export_multiline var choice_description: String

# ==================== 選擇後果 ====================
@export var energy_change: float = 0.0
@export var hp_change: int = 0
@export var mp_change: int = 0

@export var unlock_abilities: Array[String] = []
@export var lock_abilities: Array[String] = []
@export var unlock_passive: Array[String] = []
@export var lock_passive: Array[String] = []

# ==================== 世界影響 ====================
@export var world_changes: Dictionary = {}  # {"npc_id": "status", "location_id": "destroyed"}

# ==================== 劇情影響 ====================
@export_multiline var result_text: String
@export var story_flags: Dictionary = {}
@export var unlock_events: Array[String] = []  # 解鎖的後續事件ID

# ==================== 道德/情感標記 ====================
@export var moral_alignment: String = ""  # "sacrifice", "protect", "pragmatic", "idealistic"
@export var emotional_weight: int = 0  # 1-5, 情感沖擊程度
