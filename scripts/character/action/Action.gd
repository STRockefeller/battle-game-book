# Action.gd
class_name Action extends Resource

var id: String
var name: String
var description: String

var stamina_cost: int = 0
var cast_time: int = 0
var cooldown: int = 0

var allowed_stances: PackedStringArray = []
var disallowed_stances: PackedStringArray = []

var tags: PackedStringArray = []
var is_movement: bool = false

var damage_multiplier: float = 0.0
var accuracy_modifier: float = 0.0
var critical_modifier: float = 0.0

var applicable_ranges: PackedStringArray = []
var out_of_range_penalty: Dictionary = {}

var effects_on_hit: PackedStringArray = []
var effects_on_use: PackedStringArray = []
var target_stance_change_to: String = ""
var user_stance_change_to: String = ""

func is_usable_in(current_stance_id: String) -> bool:
    if allowed_stances.size() > 0:
        return allowed_stances.has(current_stance_id)
    return not disallowed_stances.has(current_stance_id)
