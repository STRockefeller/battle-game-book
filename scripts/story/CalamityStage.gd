# CalamityStage.gd
# 災變階段數據結構 - 根據能量定義世界狀態

class_name CalamityStage
extends Resource

# ==================== 階段信息 ====================
@export var stage_id: String
@export var stage_name: String
@export_multiline var stage_description: String

# ==================== 能量範圍 ====================
@export var min_energy: float = 0.0
@export var max_energy: float = 100.0

# ==================== 視覺表現 ====================
@export var world_visual_state: String = ""  # "stable", "cracking", "damaged", "collapsing", "destroyed"
@export var environment_effects: Array[String] = []  # ["fog", "fire", "darkness", etc.]
@export var color_tint: Color = Color.WHITE

# ==================== 遊戲機制影響 ====================
@export var disabled_locations: Array[String] = []  # 無法訪問的地點
@export var disabled_npcs: Array[String] = []  # 已死亡/消失的NPC
@export var passive_debuffs: Array[String] = []  # 角色受到的debuff

# ==================== 故事描述 ====================
@export_multiline var stage_narrative: String  # 進入此階段時的描述文本

# ==================== 特殊事件 ====================
@export var triggered_events: Array[String] = []  # 進入此階段自動觸發的事件ID
