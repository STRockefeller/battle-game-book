# AIBehavior.gd
# AI 行為基礎類別 - 定義 AI 做決策的方式
extends Node
class_name AIBehavior

# ==================== 配置接口（為未來資源化預留）====================

## 配置資源（未來升級時使用）
var config: Resource = null

## 從資源配置 AI 參數（預留接口）
func configure(resource: Resource) -> void:
	config = resource
	# 子類可以重寫此方法來讀取配置參數

# ==================== 核心接口 ====================

## AI 選擇動作的主要方法（子類必須實現）
## 返回值：選定的 Action，或 null 如果無法選擇
func choose_action(_character: Character, _available_actions: Array, _opponent: Character, _battle_manager: BattleManager) -> Action:
	push_error("choose_action() 未在 %s 中實現" % get_class())
	return null

# ==================== 輔助方法 ====================

## 評估單個動作的優先級（子類可重寫）
## 返回值越高表示優先級越高
func evaluate_action(_action: Action, _character: Character, _opponent: Character, _battle_manager: BattleManager) -> float:
	return 0.0

## 獲取角色當前血量比例 (0.0 - 1.0)
func get_hp_ratio(character: Character, battle_manager: BattleManager) -> float:
	var current_hp = battle_manager.get_current_hp(character)
	return float(current_hp) / float(character.max_hp) if character.max_hp > 0 else 0.0

## 獲取角色當前魔力比例 (0.0 - 1.0)
func get_mp_ratio(character: Character, battle_manager: BattleManager) -> float:
	var current_mp = battle_manager.get_current_mp(character)
	return float(current_mp) / float(character.max_mp) if character.max_mp > 0 else 0.0

## 獲取角色當前耐力比例 (0.0 - 1.0)
func get_sta_ratio(character: Character, battle_manager: BattleManager) -> float:
	var max_sta = character.constitution * 8
	var current_sta = battle_manager.get_current_sta(character)
	return float(current_sta) / float(max_sta) if max_sta > 0 else 0.0

## 獲取對手血量比例 (0.0 - 1.0)
func get_opponent_hp_ratio(opponent: Character, battle_manager: BattleManager) -> float:
	return get_hp_ratio(opponent, battle_manager)

## 檢查動作是否可以使用（資源足夠且不在冷卻中）
func can_afford_action(action: Action, character: Character, battle_manager: BattleManager) -> bool:
	var current_sta = battle_manager.get_current_sta(character)
	var current_mp = battle_manager.get_current_mp(character)
	
	# 檢查資源
	if current_sta < action.cost_stamina or current_mp < action.cost_mp:
		return false
	
	# 檢查冷卻
	var action_state = battle_manager.get_action_state(character, action)
	if action_state.has("cooldown") and action_state["cooldown"] > 0:
		return false
	
	return true

## 過濾出可以實際使用的動作
func get_affordable_actions(available_actions: Array, character: Character, battle_manager: BattleManager) -> Array:
	var affordable = []
	for action in available_actions:
		if can_afford_action(action, character, battle_manager):
			affordable.append(action)
	return affordable
