# DivineFavorData.gd
# 神明眷顧數據結構

class_name DivineFavorData
extends Resource

# ==================== 基本信息 ====================
@export var favor_id: String
@export var favor_name: String
@export_multiline var favor_description: String

# ==================== 神明屬性 ====================
@export var deity_name: String  # 神明名稱
@export var energy_type: String = ""  # 對應能量類型，空則為通用

# ==================== 眷顧類型 ====================
@export var favor_type: String = "sacrifice"  # "sacrifice", "restriction", "choice", "race", "challenge", "memory"

# ==================== 觸發條件 ====================
@export var trigger_timing: String = "pre_battle"  # "pre_battle", "during_battle", "post_battle", "turn_based"
@export var trigger_chance: float = 1.0  # 觸發機率 0.0-1.0
@export var trigger_turn: int = 0  # 如果是turn_based，在第幾回合觸發
@export var character_specific: String = ""  # 角色專屬，空則為通用

# ==================== 條件要求 ====================
@export_multiline var condition_description: String
@export var condition_type: String = ""  # "hp_sacrifice", "no_magic", "time_limit", "damage_race", etc.
@export var condition_value: float = 0.0

# ==================== 獎勵 ====================
@export var energy_reward: float = 0.0
@export var hp_reward: int = 0
@export var mp_reward: int = 0
@export var unlock_abilities: Array[String] = []
@export var grant_passive: Array[String] = []
@export var stat_buffs: Dictionary = {}  # {"strength": 2, "intelligence": -1}

# ==================== 懲罰（失敗時） ====================
@export var energy_penalty: float = 0.0
@export var hp_penalty: int = 0
@export var mp_penalty: int = 0
@export var stat_debuffs: Dictionary = {}

# ==================== 選擇型眷顧 ====================
@export var choices: Array[Resource] = []  # Array of EventChoice

# ==================== 劇情影響 ====================
@export_multiline var success_narrative: String
@export_multiline var failure_narrative: String
@export var world_impact: Dictionary = {}  # 對世界的影響

# ==================== 戰略意義 ====================
@export var difficulty_rating: int = 3  # 1-5, 完成難度
@export var risk_rating: int = 3  # 1-5, 風險程度
@export_multiline var strategy_hint: String

## 檢查是否可在當前情況下觸發
func can_trigger_for(character_id: String, battle_context: Dictionary) -> bool:
	# 檢查角色限制
	if character_specific != "" and character_specific != character_id:
		return false
	
	# 檢查能量類型匹配（如果有的話）
	if energy_type != "" and battle_context.get("energy_type", "") != energy_type:
		return false
	
	# 檢查機率
	if randf() > trigger_chance:
		return false
	
	return true
