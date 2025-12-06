extends Resource
class_name ActionProperty

enum Category { ATTACK, DEFENSE, EVADE, SUPPORT }
enum RangeType { MELEE, RANGED, MAGIC }
enum HitLevel { HIGH, MID, LOW }

@export var category: Category = Category.ATTACK
@export var range_type: RangeType = RangeType.MELEE
@export var hit_level: HitLevel = HitLevel.MID
@export var tags: Array[String] = []  # e.g. ["fire", "holy", "counter"]
