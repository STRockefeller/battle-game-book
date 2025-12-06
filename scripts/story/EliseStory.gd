# EliseStory.gd
# Elise 的故事數據資源類

class_name EliseStory extends Resource

# ==================== 角色信息 ====================

@export var character_id: String = "elise"
@export var character_name: String = "艾莉絲"
@export var title: String = "森林精靈守護者"
@export var description: String = "冷靜堅毅，責任感強，願為族人犧牲一切"

# ==================== 故鄉信息 ====================

@export var homeland_name: String = "翠綠之森"
@export var homeland_english_name: String = "Evergreen Woods"
@export var homeland_description: String = "精靈族世代居住的神聖森林，自然魔法匯聚之地"

# ==================== 災變信息 ====================

@export var calamity_name: String = "魔法失控與森林枯萎"
@export var calamity_description: String = "魔法失控導致森林枯萎，怪獸從裂縫中湧現，精靈族瀕臨滅絕"
@export var calamity_severity: float = 0.8  # 0.0 ~ 1.0，災難嚴重程度

# ==================== 故事進度 ====================

@export var initial_calamity_progress: float = 0.6  # 故事開始時的災難進度 (0.0 ~ 1.0)
@export var victory_condition_energy_required: int = 500  # 完全拯救故鄉所需的源界能量

# ==================== 特殊機制 ====================

@export var special_ability: String = "森林恢復"
@export var special_ability_description: String = "每場戰鬥表現優異，森林會恢復生機，精靈族得以反擊怪獸"
@export var energy_gain_multiplier: float = 1.2  # 能量獲得加成（表現好時）

# ==================== 角色動作 ====================

var available_moves: Array[String] = [
	"vine_lash",
	"elven_arrow",
	"nature_heal",
	"summon_vines",
	"forest_blessing"
]

# ==================== 故事開場 ====================

@export var opening_scene_title: String = "翠綠之森的末日"
@export var opening_narrative: String = """
曾經，翠綠之森是精靈族的樂園，
翠綠的樹木連綿不絕，清澈的溪流唱著古老的歌謠。
但一切都改變了...

神祕的魔法風暴吹過森林，
樹木開始枯萎，生物逐漸消亡，
從黑色的裂縫中，怪獸們不斷湧出...

精靈族正在滅亡。

而你，艾莉絲——被源界選中的森林守護者，
被賦予了拯救故鄉的使命。

你的每一場戰鬥，都決定著故鄉的未來...
"""

# ==================== 多重結局 ====================

## 拯救結局 - 完全恢復
var true_ending: String = "森林重獲生機，怪獸被完全消滅。精靈族在你的保護下得以延續，並見證了一個全新的時代的開始。"

## 中立結局 - 部分恢復
var neutral_ending: String = "雖然災難被緩解，但森林仍未完全恢復。精靈族活了下來，卻永遠失去了故鄉的一部分。"

## 悲劇結局 - 毀滅
var bad_ending: String = "森林最終消亡，精靈族逐漸凋零。你倖存下來，卻無法改變這個絕望的結局。"

## 隱藏結局 - 源界真相
var secret_ending: String = "通過一切的戰鬥，你發現了源界能量失衡的真正原因——一個黑暗的祕密正在源界的深處醞釀..."

# ==================== 故事節點 ====================

class StoryNode:
	var id: String
	var title: String
	var description: String
	var required_energy: int
	var calamity_progress_change: float
	
	func _init(p_id: String, p_title: String, p_desc: String, p_energy: int, p_change: float):
		id = p_id
		title = p_title
		description = p_desc
		required_energy = p_energy
		calamity_progress_change = p_change

# 故事關鍵節點
var story_nodes: Array[StoryNode] = [
	StoryNode.new(
		"encounter_first_monster",
		"遭遇第一隻怪獸",
		"一隻被魔法腐蝕的野獸從裂縫中出現",
		0,
		-0.05
	),
	StoryNode.new(
		"save_injured_elf",
		"拯救受傷的精靈",
		"發現一名被怪獸攻擊的同族精靈",
		50,
		-0.1
	),
	StoryNode.new(
		"purify_corrupted_grove",
		"淨化被汙染的聖林",
		"進入森林核心，與邪惡力量對抗",
		150,
		-0.15
	),
	StoryNode.new(
		"restore_nature_balance",
		"恢復自然平衡",
		"調和自然魔法，開始扭轉局勢",
		300,
		-0.2
	),
	StoryNode.new(
		"confront_origin",
		"面對源界的啟示",
		"揭露真相，決定故鄉的最終命運",
		500,
		-0.5
	)
]

# ==================== 工具函數 ====================

## 根據累積能量計算故鄉災難進度
func calculate_calamity_progress(total_energy_gained: int) -> float:
	var progress_reduction = float(total_energy_gained) / float(victory_condition_energy_required)
	progress_reduction = min(progress_reduction, 1.0)
	return max(initial_calamity_progress - progress_reduction, 0.0)

## 根據災難進度確定結局
func get_ending_type(calamity_progress: float) -> String:
	if calamity_progress <= 0.0:
		return "true_ending"
	elif calamity_progress <= 0.3:
		return "neutral_ending"
	elif calamity_progress <= 0.8:
		return "bad_ending"
	else:
		return "secret_ending"
