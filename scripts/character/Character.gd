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

# --- 初始化 ---
func _init():
	calculate_base_stats()

# 根據基礎屬性計算所有戰鬥屬性
func calculate_base_stats():
	atk = strength * 2
	matk = intelligence * 2
	def = constitution * 2
	mdef = intelligence * 2
	acc = agility * 2
	eva = agility * 2 + luck
	crt = luck * 1.0 + agility * 0.5
	max_sta = constitution * 8
