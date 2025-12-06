extends Resource
class_name Move

@export var name: String
@export var property: ActionProperty
@export var power: int = 10         # 基礎傷害
@export var cost_mp: int = 0
@export var priority: int = 0       # 行動優先度 (敏捷以外的修正)
@export var cooldown: int = 0       # 冷卻回合數
@export var apply_status: Array[Resource] = []  # 造成的狀態 (Status)
@export var condition: Dictionary = {}          # 使用條件 e.g. {"hp_below": 50}

var current_cooldown: int = 0

func can_use(user: Character) -> bool:
    if user.mp < cost_mp:
        return false
    if current_cooldown > 0:
        return false
    if condition.has("hp_below") and user.hp >= condition["hp_below"]:
        return false
    return true

func on_use(user: Character):
    user.mp -= cost_mp
    current_cooldown = cooldown
