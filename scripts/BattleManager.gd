# BattleManager.gd
extends Node
class_name BattleManager

# 信號定義
signal turn_started(active_character: Character)
signal action_resolved(user: Character, target: Character, action: Action, log: String)
signal battle_ended(winner: Character)

# 玩家
var player1: Character
var player2: Character

var characters: Array[Character] = []
var current_distance: String = "mid"

# 冷卻時間追蹤（由 BattleManager 管理，Action 等級的冷卻）
var action_cooldowns: Dictionary = {}

func _ready():
	# 初始化玩家（複製資源以避免共享狀態）
	if not player1:
		var hero_template = load("res://resources/characters/Elise.tres")
		if hero_template:
			player1 = hero_template.duplicate()
	
	if not player2:
		# 暫時也用 Elise 作為敵人（後續可改為其他角色）
		var hero_template = load("res://resources/characters/Elise.tres")
		if hero_template:
			player2 = hero_template.duplicate()
	
	characters = [player1, player2]
	
	# 初始化冷卻追蹤
	if player1:
		action_cooldowns[player1] = {}
	if player2:
		action_cooldowns[player2] = {}

## 執行一個動作
func execute_action(user: Character, target: Character, action: Action) -> bool:
	# 初始化冷卻字典（如果還沒有）
	if not action_cooldowns.has(user):
		action_cooldowns[user] = {}
	
	var user_cooldowns = action_cooldowns[user]
	
	# 1. 檢查冷卻
	if user_cooldowns.has(action.id):
		var log = "%s 無法使用 %s（冷卻中）" % [user.name, action.name]
		action_resolved.emit(user, target, action, log)
		return false
	
	# 2. 檢查 stamina 成本
	var cost = action.cost_stamina if action.cost_stamina > 0 else action.cost_mp
	if user.current_sta < cost:
		var log = "%s 沒有足夠的體力使用 %s" % [user.name, action.name]
		action_resolved.emit(user, target, action, log)
		return false
	
	# 3. 檢查 MP 成本
	if user.current_mp < action.cost_mp:
		var log = "%s 沒有足夠的魔力使用 %s" % [user.name, action.name]
		action_resolved.emit(user, target, action, log)
		return false
	
	# 4. 扣資源
	user.current_sta -= cost
	user.current_mp -= action.cost_mp
	
	# 5. 計算命中 & 傷害
	var user_acc = user.get_effective_stat("acc")
	var target_eva = target.get_effective_stat("eva")
	var accuracy = user_acc + action.accuracy_modifier
	var damage = user.get_effective_stat("atk") * action.damage_multiplier
	
	# 檢查距離是否符合（如果有距離系統）
	if action.applicable_ranges.size() > 0 and not action.applicable_ranges.has(current_distance):
		if action.out_of_range_penalty.has("accuracy_modifier"):
			accuracy += action.out_of_range_penalty["accuracy_modifier"]
		if action.out_of_range_penalty.has("damage_multiplier"):
			damage *= action.out_of_range_penalty["damage_multiplier"]

	var hit = _roll_hit(accuracy, target_eva)
	var log = "%s 使用了 %s" % [user.name, action.name]
	
	if hit:
		var target_def = target.get_effective_stat("def")
		var final_damage = max(1, int(damage) - int(target_def))
		target.take_damage(final_damage)
		log += "！造成 %d 傷害" % final_damage
		
		# 6. 應用狀態效果（如果有）
		if action.applies_status_effect != null:
			target.apply_effect(action.applies_status_effect)
			log += "，並附加 %s" % action.applies_status_effect.name
		
		# 7. 改變姿態（如果有）
		if action.changes_stance_to != Stance.Type.STANDING:
			target.change_stance(action.changes_stance_to, action.stance_duration)
			log += "，改變為 %s 姿態" % Stance.get_name(action.changes_stance_to)
	else:
		log += "，但沒有命中！"
	
	# 8. 設置冷卻
	if action.cooldown > 0:
		user_cooldowns[action.id] = action.cooldown
	
	# 9. 檢查戰鬥是否結束
	if target.current_hp <= 0:
		battle_ended.emit(user)
		return true
	
	# 10. 發送信號
	action_resolved.emit(user, target, action, log)
	
	return true

## 降低所有動作的冷卻時間
func reduce_cooldowns(character: Character):
	if action_cooldowns.has(character):
		var cooldowns = action_cooldowns[character]
		var actions_to_remove = []
		
		for action_id in cooldowns:
			cooldowns[action_id] -= 1
			if cooldowns[action_id] <= 0:
				actions_to_remove.append(action_id)
		
		for action_id in actions_to_remove:
			cooldowns.erase(action_id)

## 單次戰鬥回合（兩個玩家依序選擇和執行動作）
func execute_round():
	# 玩家 1 的回合
	turn_started.emit(player1)
	# 等待玩家選擇（由 Battle.gd UI 處理）
	
	# 玩家 2 的回合
	turn_started.emit(player2)
	# 等待玩家選擇（由 Battle.gd UI 處理）
	
	# 回合結束：更新冷卻和效果
	for character in characters:
		reduce_cooldowns(character)
		character.on_turn_end()

func _roll_hit(acc: float, eva: float) -> bool:
	var chance = acc - eva
	return randf() * 100 < clamp(chance, 5, 95)
