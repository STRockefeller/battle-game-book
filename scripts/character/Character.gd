# Character.gd
class_name Character extends Resource

# --- 基本信息 ---
@export var name: String = ""

# --- 基礎屬性 (永久性) ---
@export var strength: int = 0
@export var intelligence: int = 0
@export var agility: int = 0
@export var constitution: int = 0
@export var luck: int = 0

# --- 最大值 (永久性) ---
@export var max_hp: int = 100
@export var max_mp: int = 50

# --- 計算的戰鬥屬性 (唯讀) ---
var atk: int = 0
var matk: int = 0
var def: int = 0
var mdef: int = 0
var acc: int = 0
var eva: int = 0
var crt: float = 0.0
var max_sta: int = 0

# --- 當前值 ---
var current_hp: int = 0
var current_mp: int = 0
var current_sta: int = 0

# --- 動作列表 ---
@export var available_actions: Array[Action] = []

# --- 狀態效果系統 ---
var effect_manager: StatusEffectManager

# --- 初始化 ---
func _init() -> void:
	calculate_base_stats()
	current_hp = max_hp
	current_mp = max_mp
	current_sta = max_sta
	effect_manager = StatusEffectManager.new(self)

# 根據基礎屬性計算所有戰鬥屬性
func calculate_base_stats() -> void:
	atk = strength * 2
	matk = intelligence * 2
	def = constitution * 2
	mdef = intelligence * 2
	acc = agility * 2
	eva = agility * 2 + luck
	crt = luck * 1.0 + agility * 0.5
	max_sta = constitution * 8

# ==================== 效果系統整合 ====================

## 應用一個狀態效果到此角色
func apply_effect(effect: StatusEffect) -> void:
	effect_manager.apply_effect(effect)

## 移除一個狀態效果
func remove_effect(effect_id: String) -> void:
	effect_manager.remove_effect(effect_id)

## 在回合開始時調用
func on_turn_start() -> void:
	effect_manager.on_turn_start()

## 在回合結束時調用
func on_turn_end() -> void:
	effect_manager.on_turn_end()

## 獲取指定屬性的有效值（包含修正）
func get_effective_stat(stat: String) -> int:
	var base_value = 0
	
	match stat:
		"atk":
			base_value = atk
		"matk":
			base_value = matk
		"def":
			base_value = def
		"mdef":
			base_value = mdef
		"acc":
			base_value = acc
		"eva":
			base_value = eva
	
	return base_value + effect_manager.get_stat_modifier(stat)

# ==================== 生命值管理 ====================

## 造成傷害（用於效果觸發時調用）
func take_damage(damage: int) -> void:
	current_hp -= damage
	current_hp = max(0, current_hp)
	print("%s 受到 %d 傷害，當前 HP: %d/%d" % [name, damage, current_hp, max_hp])

## 恢復生命值（用於效果觸發時調用）
func heal(amount: int) -> void:
	current_hp += amount
	current_hp = min(current_hp, max_hp)
	print("%s 恢復 %d 生命值，當前 HP: %d/%d" % [name, amount, current_hp, max_hp])

## 檢查角色是否還活著
func is_alive() -> bool:
	return current_hp > 0
