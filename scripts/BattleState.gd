# BattleState.gd
# 戰鬥狀態序列化和管理類
# 用於伺服器-客戶端同步和狀態驗證
extends RefCounted
class_name BattleState

# ==================== 戰鬥進度 ====================

## 當前回合數
var turn: int = 0

## 最大回合數
var max_turns: int = 100

# ==================== 戰場距離 ====================

## 戰鬥距離（0=近、1=中、2=遠）
enum Distance {
	NEAR,
	MID,
	FAR
}

var distance: int = Distance.MID

# ==================== 玩家 1 狀態 ====================

var p1_current_hp: int = 0
var p1_current_mp: int = 0
var p1_current_stamina: int = 0
var p1_stance: int = 0  # Stance.Type enum 值

# ==================== 玩家 2 狀態 ====================

var p2_current_hp: int = 0
var p2_current_mp: int = 0
var p2_current_stamina: int = 0
var p2_stance: int = 0  # Stance.Type enum 值

# ==================== 冷卻管理 ====================

## {action_id: remaining_cooldown}
var p1_cooldowns: Dictionary = {}
var p2_cooldowns: Dictionary = {}

# ==================== 初始化 ====================

func _init(
	p1_max_hp: int = 0,
	p1_max_mp: int = 0,
	p1_max_stamina: int = 0,
	p2_max_hp: int = 0,
	p2_max_mp: int = 0,
	p2_max_stamina: int = 0
) -> void:
	p1_current_hp = p1_max_hp
	p1_current_mp = p1_max_mp
	p1_current_stamina = p1_max_stamina
	
	p2_current_hp = p2_max_hp
	p2_current_mp = p2_max_mp
	p2_current_stamina = p2_max_stamina
	
	turn = 1
	max_turns = 100
	distance = Distance.MID

# ==================== 序列化 ====================

## 轉換為字典，用於網路傳輸
func to_dict() -> Dictionary:
	return {
		"turn": turn,
		"max_turns": max_turns,
		"distance": distance,
		"p1": {
			"hp": p1_current_hp,
			"mp": p1_current_mp,
			"stamina": p1_current_stamina,
			"stance": p1_stance,
			"cooldowns": p1_cooldowns.duplicate()
		},
		"p2": {
			"hp": p2_current_hp,
			"mp": p2_current_mp,
			"stamina": p2_current_stamina,
			"stance": p2_stance,
			"cooldowns": p2_cooldowns.duplicate()
		}
	}

## 從字典載入狀態
func from_dict(data: Dictionary) -> void:
	turn = data.get("turn", 1)
	max_turns = data.get("max_turns", 100)
	distance = clamp(
		data.get("distance", Distance.MID),
		Distance.NEAR,
		Distance.FAR
	)
	
	if data.has("p1"):
		var p1_data = data["p1"]
		p1_current_hp = p1_data.get("hp", 0)
		p1_current_mp = p1_data.get("mp", 0)
		p1_current_stamina = p1_data.get("stamina", p1_data.get("sta", 0))
		p1_stance = p1_data.get("stance", 0)
		p1_cooldowns = p1_data.get("cooldowns", {}).duplicate()
	
	if data.has("p2"):
		var p2_data = data["p2"]
		p2_current_hp = p2_data.get("hp", 0)
		p2_current_mp = p2_data.get("mp", 0)
		p2_current_stamina = p2_data.get("stamina", p2_data.get("sta", 0))
		p2_stance = p2_data.get("stance", 0)
		p2_cooldowns = p2_data.get("cooldowns", {}).duplicate()

# ==================== 狀態查詢 ====================

## 獲取玩家 1 狀態
func get_p1_state() -> Dictionary:
	return {
		"hp": p1_current_hp,
		"mp": p1_current_mp,
		"stamina": p1_current_stamina,
		"stance": p1_stance,
		"cooldowns": p1_cooldowns
	}

## 獲取玩家 2 狀態
func get_p2_state() -> Dictionary:
	return {
		"hp": p2_current_hp,
		"mp": p2_current_mp,
		"stamina": p2_current_stamina,
		"stance": p2_stance,
		"cooldowns": p2_cooldowns
	}

## 獲取玩家狀態（1 或 2）
func get_player_state(player_id: int) -> Dictionary:
	return get_p1_state() if player_id == 1 else get_p2_state()

# ==================== 狀態修改 ====================

## 更新玩家 1 狀態
func set_p1_state(hp: int, mp: int, stamina: int, stance: int) -> void:
	p1_current_hp = hp
	p1_current_mp = mp
	p1_current_stamina = stamina
	p1_stance = stance

## 更新玩家 2 狀態
func set_p2_state(hp: int, mp: int, stamina: int, stance: int) -> void:
	p2_current_hp = hp
	p2_current_mp = mp
	p2_current_stamina = stamina
	p2_stance = stance

## 更新玩家狀態（1 或 2）
func set_player_state(player_id: int, hp: int, mp: int, stamina: int, stance: int) -> void:
	if player_id == 1:
		set_p1_state(hp, mp, stamina, stance)
	else:
		set_p2_state(hp, mp, stamina, stance)

# ==================== 冷卻管理 ====================

## 更新玩家 1 冷卻
func set_p1_cooldowns(cooldowns: Dictionary) -> void:
	p1_cooldowns = cooldowns.duplicate()

## 更新玩家 2 冷卻
func set_p2_cooldowns(cooldowns: Dictionary) -> void:
	p2_cooldowns = cooldowns.duplicate()

## 更新玩家冷卻（1 或 2）
func set_player_cooldowns(player_id: int, cooldowns: Dictionary) -> void:
	if player_id == 1:
		set_p1_cooldowns(cooldowns)
	else:
		set_p2_cooldowns(cooldowns)

## 獲取玩家冷卻
func get_player_cooldowns(player_id: int) -> Dictionary:
	return p1_cooldowns if player_id == 1 else p2_cooldowns

# ==================== 驗證和簽名 ====================

## 計算狀態簽名用於驗證（防止篡改）
func calculate_hash() -> String:
	var state_str = "%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d" % [
		turn,
		distance,
		p1_current_hp, p1_current_mp, p1_current_stamina, p1_stance,
		p2_current_hp, p2_current_mp, p2_current_stamina, p2_stance,
		p1_cooldowns.size(),
		p2_cooldowns.size(),
		max_turns
	]
	return state_str.md5_text()

## 驗證狀態一致性
func verify_hash(expected_hash: String) -> bool:
	return calculate_hash() == expected_hash

# ==================== 戰鬥結束檢查 ====================

## 檢查戰鬥是否結束
func is_battle_ended() -> bool:
	# 直接計算，無需調用 BattleLogic
	return p1_current_hp <= 0 or p2_current_hp <= 0

## 獲取勝者（1、2、0=平局、-1=未結束）
func get_winner() -> int:
	if p1_current_hp <= 0 and p2_current_hp > 0:
		return 2
	elif p2_current_hp <= 0 and p1_current_hp > 0:
		return 1
	elif p1_current_hp <= 0 and p2_current_hp <= 0:
		return 0
	else:
		return -1

## 檢查特定玩家是否已敗北
func is_player_defeated(player_id: int) -> bool:
	if player_id == 1:
		return p1_current_hp <= 0
	else:
		return p2_current_hp <= 0

# ==================== 進度檢查 ====================

## 檢查是否達到最大回合數
func has_reached_max_turns() -> bool:
	return turn >= max_turns
