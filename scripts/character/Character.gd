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

# --- 動作列表 ---
@export var available_actions: Array[Action] = []

# --- 狀態效果系統 ---
var effect_manager: StatusEffectManager

# --- 姿態系統 ---
var stance_manager: StanceManager

# --- 初始化 ---
func _init() -> void:
	calculate_base_stats()
	effect_manager = StatusEffectManager.new(self)
	stance_manager = StanceManager.new(self)

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

# ==================== 姿態系統整合 ====================

## 改變角色的姿態
func change_stance(stance_type: Stance.Type, duration: int = -1) -> void:
	stance_manager.change_stance(stance_type, duration)

## 獲取當前姿態
func get_current_stance() -> Stance.Type:
	return stance_manager.get_current_stance_type()

## 獲取當前姿態名稱
func get_current_stance_name() -> String:
	return stance_manager.get_current_stance_name()

## 檢查角色是否可以執行特定動作
func can_perform_action(action_tag: String) -> bool:
	return stance_manager.can_perform_action(action_tag)

## 檢查是否處於特定姿態
func is_stance(stance_type: Stance.Type) -> bool:
	return stance_manager.is_stance(stance_type)

# ==================== 效果系統整合 ====================

## 應用一個狀態效果到此角色
func apply_effect(effect: StatusEffect) -> void:
	effect_manager.apply_effect(effect)

## 移除一個狀態效果
func remove_effect(effect_id: String) -> void:
	effect_manager.remove_effect(effect_id)

## 在回合開始時調用
func on_turn_start() -> void:
	stance_manager.on_turn_start()
	effect_manager.on_turn_start()

## 在回合結束時調用
func on_turn_end() -> void:
	stance_manager.on_turn_end()
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
	
	# 獲取效果修正值
	var effect_modifier = effect_manager.get_stat_modifier(stat)
	
	# 獲取姿態修正值
	var stance_modifier = stance_manager.get_stance_stat_modifier(stat)
	
	return base_value + effect_modifier + stance_modifier

# ==================== 生命值管理 ====================

## 造成傷害（用於效果觸發時調用）
func take_damage(damage: int) -> void:
	# 此方法現在由 BattleManager 調用並管理傷害
	# Character 本身不再維護 current_hp
	print("%s 受到 %d 傷害" % [name, damage])

## 恢復生命值（用於效果觸發時調用）
func heal(amount: int) -> void:
	# 此方法現在由 BattleManager 調用並管理治療
	# Character 本身不再維護 current_hp
	print("%s 恢復 %d 生命值" % [name, amount])

## 檢查角色是否還活著（需要由 BattleManager 提供 current_hp）
func is_alive(current_hp: int) -> bool:
	return current_hp > 0
