# Action.gd
extends Resource
class_name Action

# --- 基本信息 ---
@export var id: String
@export var name: String
@export var description: String

# --- 視覺和音效資源 ---
@export var action_assets: ActionAssets = null  # 動作的所有視覺資源定義

# --- 動畫時長 ---
@export var animation_duration: float = 0.5  # 動畫持續時間（秒）

# --- 成本 ---
@export var cost_stamina: int = 0
@export var cost_mp: int = 0 
@export var cooldown: int = 0

# --- 命中與爆擊（由積木系統細緻控制）---
@export var accuracy: float = 100.0      # 基礎命中率 (%)
@export var critical_rate: float = 0.0   # 基礎爆擊率 (%)

# --- 距離相關 ---
@export var accuracy_by_range: Dictionary = {}  # { "near": 95.0, "mid": 85.0, "far": 60.0 }

# --- 姿態限制 ---
@export var allowed_stances: Array[Stance.Type] = []
@export var disallowed_stances: Array[Stance.Type] = []

# --- 標籤與分類 ---
@export var tags: Array[ActionTags.Tags] = []

# --- 效果系統 ---
## 模組化效果系統：使用 EffectComponent 積木組合
@export var effects: Array[EffectComponent] = []

@export var priority: int = 0  # 行動優先度

# 動作當前冷卻時間
var current_cooldown: int = 0

func can_use(user: Character, battle_manager: BattleManager = null) -> bool:
	if not battle_manager:
		return true  # 無法驗證，視為可用
	
	# 使用 cost_mp 或 cost_stamina
	var cost = cost_stamina if cost_stamina > 0 else cost_mp
	if battle_manager.get_current_stamina(user) < cost:
		return false
	
	# 檢查冷卻時間
	var cooldowns = battle_manager.get_action_cooldowns(user)
	if cooldowns.has(id):
		return false
	
	return true

func is_usable_in(current_stance_type: Stance.Type) -> bool:
	if allowed_stances.size() > 0:
		return allowed_stances.has(current_stance_type)
	return not disallowed_stances.has(current_stance_type)

## 獲取指定距離的命中率（如無則返回基礎命中率）
func get_accuracy_at_range(range_type: String) -> float:
	if accuracy_by_range.has(range_type):
		return accuracy_by_range[range_type]
	return accuracy

## 檢查此動作是否使用新的效果積木系統
func uses_effect_components() -> bool:
	return effects.size() > 0

## 獲取特定執行時機的效果列表
func get_effects_by_time(execution_time: EffectComponent.ExecutionTime) -> Array[EffectComponent]:
	var filtered: Array[EffectComponent] = []
	for effect in effects:
		if effect.execution_time == execution_time:
			filtered.append(effect)
	return filtered

## 獲取特定條件類型的效果列表
func get_effects_by_condition(condition_type: EffectComponent.ConditionType) -> Array[EffectComponent]:
	var filtered: Array[EffectComponent] = []
	for effect in effects:
		if effect.condition_type == condition_type:
			filtered.append(effect)
	return filtered
