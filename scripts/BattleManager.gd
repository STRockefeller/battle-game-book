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

# 戰鬥狀態 (由 BattleManager 管理)
# 角色的臨時狀態字典
var character_states: Dictionary = {}

func _ready():
	# 初始化玩家（複製資源以避免共享狀態）
	if not player1:
		var hero_template = load("res://resources/characters/Hero.tres")
		if hero_template:
			player1 = hero_template.duplicate()
	
	if not player2:
		var hero_template = load("res://resources/characters/Hero.tres")
		if hero_template:
			player2 = hero_template.duplicate()
	
	# 初始化玩家戰鬥狀態
	if player1:
		_initialize_character_state(player1)
	if player2:
		_initialize_character_state(player2)
	
	characters = [player1, player2]

# 為角色初始化戰鬥狀態
func _initialize_character_state(character: Character):
	var state = {
		"hp": character.max_hp,
		"mp": character.max_mp,
		"sta": character.max_sta,
		"current_stance": "default",
		"action_cooldowns": {},
		"active_effects": []
	}
	character_states[character] = state

# 獲取角色的 HP
func get_hp(character: Character) -> int:
	if character_states.has(character):
		return character_states[character]["hp"]
	return character.max_hp

# 設置角色的 HP
func set_hp(character: Character, value: int):
	if character_states.has(character):
		character_states[character]["hp"] = clamp(value, 0, character.max_hp)

# 獲取角色的 MP
func get_mp(character: Character) -> int:
	if character_states.has(character):
		return character_states[character]["mp"]
	return character.max_mp

# 設置角色的 MP
func set_mp(character: Character, value: int):
	if character_states.has(character):
		character_states[character]["mp"] = clamp(value, 0, character.max_mp)

# 獲取角色的 STA
func get_sta(character: Character) -> int:
	if character_states.has(character):
		return character_states[character]["sta"]
	return character.max_sta

# 設置角色的 STA
func set_sta(character: Character, value: int):
	if character_states.has(character):
		character_states[character]["sta"] = clamp(value, 0, character.max_sta)

# 獲取角色的冷卻時間字典
func get_action_cooldowns(character: Character) -> Dictionary:
	if character_states.has(character):
		return character_states[character]["action_cooldowns"]
	return {}

# 執行一個動作
func execute_action(user: Character, target: Character, action: Action) -> bool:
	var user_cooldowns = get_action_cooldowns(user)
	var user_sta = get_sta(user)
	
	# 1. 檢查冷卻
	if user_cooldowns.has(action.id):
		return false
	
	# 2. 檢查 stamina 成本
	var cost = action.stamina_cost if action.stamina_cost > 0 else action.cost_mp
	if user_sta < cost:
		return false
	
	# 3. 扣 stamina
	set_sta(user, user_sta - cost)
	
	# 4. 計算命中 & 傷害
	var accuracy = user.acc + action.accuracy_modifier
	var damage = user.atk * action.damage_multiplier
	if not action.applicable_ranges.has(current_distance):
		if action.out_of_range_penalty.has("accuracy_modifier"):
			accuracy += action.out_of_range_penalty["accuracy_modifier"]
		if action.out_of_range_penalty.has("damage_multiplier"):
			damage *= action.out_of_range_penalty["damage_multiplier"]

	var hit = _roll_hit(accuracy, target.eva)
	var log = "%s 使用了 %s" % [user.name, action.name]
	
	if hit:
		var final_damage = max(0, damage - target.def)
		set_hp(target, get_hp(target) - final_damage)
		log += "！造成 %d 傷害" % final_damage
	else:
		log += "，但沒有命中！"
	
	# 5. 設置冷卻
	if action.cooldown > 0:
		user_cooldowns[action.id] = action.cooldown
	
	# 6. 發送信號
	action_resolved.emit(user, target, action, log)
	
	return true

func _roll_hit(acc: float, eva: float) -> bool:
	var chance = acc - eva
	return randf() * 100 < clamp(chance, 5, 95)

func load_effect(effect_id: String) -> StatusEffect:
	# TODO: 從資源庫載入
	return null

func load_stance(stance_id: String) -> Stance:
	# TODO: 從資源庫載入
	return null
